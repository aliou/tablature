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

      # Raised when trying to create a list partition without specifying the values of the partition
      # key.
      class MissingListPartitionValuesError < StandardError
        def initialize
          super('Missing values for of list partition')
        end
      end

      # Raised when a range partition operation is attempted on a database
      # version that does not support range partitions.
      #
      # Range partitions are supported on Postgres 10 or newer.
      class RangePartitionsNotSupportedError < StandardError
        def initialize
          super('Range partitions require Postgres 10 or newer')
        end
      end

      # Raised when trying to create a range partition without specifying the range of the partition
      # key.
      class MissingRangePartitionBoundsError < StandardError
        def initialize
          super('Missing bounds for of range partition')
        end
      end
    end
  end
end
