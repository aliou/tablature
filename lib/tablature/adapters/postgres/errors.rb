module Tablature
  module Adapters
    class Postgres
      # Raised when a list partition operation is attempted on a database
      # version that does not support list partitions.
      #
      # List partitions are supported on Postgres 10 or newer.
      class ListPartitionsNotSupportedError < StandardError
        def initialize
          super('List partitions require Postgres 10 or newer')
        end
      end
    end
  end
end
