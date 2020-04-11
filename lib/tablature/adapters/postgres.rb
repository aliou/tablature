require 'active_support/core_ext/module/delegation'

require_relative 'postgres/connection'
require_relative 'postgres/errors'
require_relative 'postgres/handlers/list'
require_relative 'postgres/handlers/range'
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
    # These methods are used internally by Tablature and are not intended for direct
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
      #   for Tablature to use. Defaults to +ActiveRecord::Base+.
      #
      # @example
      #  Tablature.configure do |config|
      #    config.database = Tablature::Adapters::Postgres.new
      #  end
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      # @!method create_list_partition(table_name, options, &block)
      # Creates a partitioned table using the list partition method.
      #
      # This is called in a migration via {Statements#create_list_partition}.
      #
      # @param [String, Symbol] table_name The name of the table to partition.
      # @param [Hash] options The options to create the partition. Keys besides +:partition_key+
      #   will be passed to +create_table+.
      # @option options [String, Symbol, #call] :partition_key The partition key.
      # @yield [td] A TableDefinition object. This allows creating the table columns the same way
      #   as Rails's +create_table+ does.
      #
      # @example
      #   create_list_partition :events, partition_key: :id
      #
      # @example
      #   create_list_partition :events, partition_key: :date do |t|
      #     t.date :date, null: false
      #   end
      delegate :create_list_partition, to: :list_handler

      # @!method create_list_partition_of(parent_table_name, options)
      # Creates a partition of a parent by specifying the key values appearing in the partition.
      #
      # @param parent_table_name [String, Symbol] The name of the parent table.
      # @param [Hash] options The options to create the partition.
      # @option options [String, Symbol] :values The values appearing in the partition.
      # @option options [String, Symbol] :name The name of the partition. If it is not given, this
      #   will be randomly generated.
      # @option options [Boolean] :default Whether the partition is the default partition or not.
      #
      # @example
      #   # With a table :events partitioned using the list method on the partition key `date`:
      #   create_list_partition_of :events, name: "events_2018-W49", values: [
      #     "2018-12-03", "2018-12-04", "2018-12-05", "2018-12-06", "2018-12-07", "2018-12-08", "2018-12-09"
      #   ]
      delegate :create_list_partition_of, to: :list_handler

      # @!method attach_to_list_partition(parent_table_name, options)
      # Attaches a partition to a parent by specifying the key values appearing in the partition.
      #
      # @param parent_table_name [String, Symbol] The name of the parent table.
      # @param [Hash] options The options to attach the partition.
      # @option options [String, Symbol] :name The name of the partition.
      # @option options [String, Symbol] :values The values appearing in the partition.
      #
      # @example
      #   # With a table :events partitioned using the list method on the partition key `date`:
      #   attach_to_list_partition :events, name: "events_2018-W49", values: [
      #     "2018-12-03", "2018-12-04", "2018-12-05", "2018-12-06", "2018-12-07", "2018-12-08", "2018-12-09"
      #   ]
      delegate :attach_to_list_partition, to: :list_handler

      # @!method detach_from_list_partition(parent_table_name, options)
      # Detaches a partition from a parent.
      #
      # @param parent_table_name [String, Symbol] The name of the parent table.
      # @param [Hash] options The options to create the partition.
      # @option options [String, Symbol] :name The name of the partition.
      #
      # @example
      #   # With a table :events partitioned using the list method on the partition key `date`:
      #   detach_from_list_partition :events, name: "events_2018-W49"
      delegate :detach_from_list_partition, to: :list_handler

      # @!method create_range_partition(table_name, options, &block)
      # Creates a partitioned table using the range partition method.
      #
      # This is called in a migration via {Statements#create_range_partition}.
      #
      # @param [String, Symbol] table_name The name of the table to partition.
      # @param [Hash] options The options to create the partition. Keys besides +:partition_key+
      #   will be passed to +create_table+.
      # @yield [td] A TableDefinition object. This allows creating the table columns the same way
      #   as Rails's +create_table+ does.
      #
      # @example
      #   create_range_partition :events, partition_key: :id
      #
      # @example
      #   create_range_partition :events, partition_key: :date do |t|
      #     t.date :date, null: false
      #   end
      delegate :create_range_partition, to: :range_handler

      # @!method create_range_partition_of(parent_table_name, options)
      # Creates a partition of a parent by specifying the bound of the values appearing in the
      #   partition.
      #
      # @param parent_table_name [String, Symbol] The name of the parent table.
      # @param [Hash] options The options to create the partition.
      # @option options [String, Symbol] :range_start The start of the range of values appearing in
      #   the partition.
      # @option options [String, Symbol] :range_end The end of the range of values appearing in
      #   the partition.
      # @option options [String, Symbol] :name The name of the partition. If it is not given, this
      #   will be randomly generated.
      # @option options [Boolean] :default Whether the partition is the default partition or not.
      #
      # @example
      #   # With a table :events partitioned using the range method on the partition key `date`:
      #   create_range_partition_of :events, name: "events_2018-W49", range_start: '2018-12-03',
      #                                                               range_end: '2018-12-10'
      delegate :create_range_partition_of, to: :range_handler

      # Returns an array of partitioned tables in the database.
      #
      # This collection of tables is used by the [Tablature::SchemaDumper] to populate the schema.rb
      # file.
      #
      # @return [Array<Tablature::PartitionedTable]
      def partitioned_tables
        PartitionedTables.new(connection).all
      end

      private

      attr_reader :connectable

      def connection
        Connection.new(connectable.connection)
      end

      def list_handler
        @list_handler ||= Handlers::List.new(connection)
      end

      def range_handler
        @range_handler ||= Handlers::Range.new(connection)
      end
    end
  end
end
