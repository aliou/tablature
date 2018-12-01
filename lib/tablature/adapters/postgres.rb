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

      delegate :create_list_partition, :create_list_partition_of, to: :list_handler
      delegate :create_range_partition, :create_range_partition_of, to: :range_handler

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
