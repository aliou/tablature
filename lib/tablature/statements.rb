module Tablature
  # Methods that are made available in migrations.
  module Statements
    # Creates a new list partition.
    #
    # @param name [String, Symbol] The name of the partition.
    # @param partition_key [String, Proc] The name of the partition.
    def create_list_partition(name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_list_partition(name, options, &block)
    end

    def create_range_partition(name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_range_partition(name, options, &block)
    end
  end
end
