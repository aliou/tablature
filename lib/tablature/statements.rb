module Tablature
  # Methods that are made available in migrations.
  module Statements
    # Creates a new list partition.
    #
    # @param name [String, Symbol] The name of the partition.
    # @param partition_key [String, Proc] The name of the partition.
    def create_list_partition(name, partition_key:, &block)
      raise ArgumentError, 'partition_key must be defined' if partition_key.nil?

      Tablature.database.create_list_partition(name, partition_key: partition_key, &block)
    end
  end
end
