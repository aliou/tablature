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

    def create_list_partition_of(parent_table, options)
      raise ArgumentError, 'values must be defined' if options[:values].nil?

      Tablature.database.create_list_partition_of(parent_table, options)
    end

    def create_range_partition(name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_range_partition(name, options, &block)
    end

    def create_range_partition_of(parent_table, options)
      if options[:range_start].nil? || options[:range_end].nil?
        raise ArgumentError, 'range_start and range_end must be defined'
      end

      Tablature.database.create_range_partition_of(parent_table, options)
    end
  end
end
