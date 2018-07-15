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
    end
  end
end
