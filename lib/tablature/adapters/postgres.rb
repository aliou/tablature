require_relative 'postgres/connection'
require_relative 'postgres/errors'
require_relative 'postgres/partitioned_tables'
require_relative 'postgres/quoting'
require_relative 'postgres/uuid'

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
      include Quoting
      include UUID

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

      def create_list_partition(table_name, options, &block)
        raise_unless_list_partition_supported

        # Postgres 10 does not handle indexes and therefore primary keys.
        # Therefore we manually create an `id` column.
        # TODO: Either make the library Postgres 11 only, or two code paths between Postgres 10 and
        # Postgres 11.
        modified_options = options.except(:id, :primary_key, :partition_key)
        id_options = extract_primary_key!(options.slice(:id, :primary_key))
        partition_key = options.fetch(:partition_key)

        modified_options[:id]      = false
        modified_options[:options] = "PARTITION BY LIST (#{quote_partition_key(partition_key)})"

        create_partition(table_name, id_options, modified_options, &block)
      end

      def create_range_partition(table_name, options, &block)
        raise_unless_range_partition_supported

        # Postgres 10 does not handle indexes and therefore primary keys.
        # Therefore we manually create an `id` column.
        # TODO: Either make the library Postgres 11 only, or two code paths between Postgres 10 and
        # Postgres 11.
        modified_options = options.except(:id, :primary_key, :partition_key)
        id_options = extract_primary_key!(options.slice(:id, :primary_key))
        partition_key = options.fetch(:partition_key)

        modified_options[:id]      = false
        modified_options[:options] = "PARTITION BY RANGE (#{quote_partition_key(partition_key)})"

        create_partition(table_name, id_options, modified_options, &block)
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

      def create_partition(table_name, id_options, table_options, &block)
        create_table(table_name, table_options) do |td|
          # TODO: Handle the id things here (depending on the postgres version)
          if id_options[:type] == :uuid
            td.column(
              id_options[:column_name], id_options[:type], null: false, default: uuid_function
            )
          elsif id_options[:type]
            td.column(id_options[:column_name], id_options[:type], null: false)
          end

          yield(td) if block.present?
        end
      end

      def raise_unless_list_partition_supported
        raise ListPartitionsNotSupportedError unless connection.supports_list_partitions?
      end

      def raise_unless_range_partition_supported
        raise RangePartitionsNotSupportedError unless connection.supports_range_partitions?
      end

      def extract_primary_key!(options)
        type = options.fetch(:id, :bigserial)
        column_name = options.fetch(:primary_key, :id)

        raise ArgumentError, 'composite primary key not supported' if column_name.is_a?(Array)

        { type: type, column_name: column_name }
      end
    end
  end
end
