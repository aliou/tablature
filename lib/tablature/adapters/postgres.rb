require_relative 'postgres/connection'
require_relative 'postgres/errors'
require_relative 'postgres/partitioned_tables'

module Tablature
  # Tablature database adapters.
  #
  # Tablature ships with a Postgres adapter only but can be extended with
  # additional adapters. The {Adapters::Postgres} adapter provides the
  # interface.
  module Adapters
    # An adapter for managing Postgres views.
    #
    # These methods are used interally by Tablature and are not intended for direct
    # use. Methods that alter database schema are intended to be called via
    # {Statements}.
    #
    # The methods are documented here for insight into specifics of how Tablature
    # integrates with Postgres and the responsibilities of {Adapters}.
    class Postgres
      # Creates an instance of the Tablature Postgres adapter.
      #
      # This is the default adapter for Tablature. Configuring it via
      # {Tablature.configure} is not required, but the example below shows how one
      # would explicitly set it.
      #
      # @param [#connection] connectable An object that returns the connection
      #   for Tablature to use. Defaults to `ActiveRecord::Base`.
      #
      # @example
      #  Tablature.configure do |config|
      #    config.database = Tablature::Adapters::Postgres.new
      #  end
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      # TODO: Check version of postgres.
      def create_list_partition(table_name, partition_key:, **options)
        raise_unless_list_partition_supported

        # Postgres 10 does not handle indexes and therefore primary keys.
        # Therefore we manually create an `id` column.
        # TODO: Either make the library Postgres 11 only, or two code paths between Postgres 10 and
        # Postgres 11.
        modified_options = options.except(:id, :primary_key)
        id               = options.fetch(:id, :bigserial)
        primary_key      = options.fetch(:primary_key, :id)

        raise ArgumentError, 'composite primary key not supported' if primary_key.is_a?(Array)

        modified_options[:id]      = false
        modified_options[:options] = "PARTITION BY LIST (#{quote_partition_key(partition_key)})"

        result = create_table(table_name, modified_options) do |td|
          if id == :uuid
            td.column(primary_key, id, null: false, default: uuid_function)
          elsif id
            td.column(primary_key, id, null: false)
          end

          yield(td) if block_given?
        end

        result
      end

      def partitioned_tables
        PartitionedTables.new(connection).all
      end

      private

      attr_reader :connectable

      delegate :execute, :quote_column_name, :create_table, to: :connection

      def connection
        Connection.new(connectable.connection)
      end

      def raise_unless_list_partition_supported
        raise ListPartitionsNotSupportedError unless connection.supports_list_partitions?
      end

      def quote_partition_key(key)
        key.to_s.split('::').map(&method(:quote_column_name)).join('::')
      end

      def uuid_function
        try(:supports_pgcrypto_uuid?) ? 'gen_random_uuid()' : 'uuid_generate_v4()'
      end
    end
  end
end
