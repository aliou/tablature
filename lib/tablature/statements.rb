module Tablature
  # Methods that are made available in migrations.
  module Statements
    # Creates a partitioned table using the list partition method.
    #
    # @param name [String, Symbol] The name of the partition.
    # @param options [Hash] The options to create the partition.
    # @yield [td] A TableDefinition object. This allows creating the table columns the same way
    #   as Rails's +create_table+ does.
    # @see Tablature::Adapters::Postgres#create_list_partition
    def create_list_partition(name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_list_partition(name, options, &block)
    end

    # Creates a partition of a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#create_list_partition_of
    def create_list_partition_of(parent_table_name, options)
      raise ArgumentError, 'values must be defined' if options[:values].nil?

      Tablature.database.create_list_partition_of(parent_table_name, options)
    end

    # Creates a partitioned table using the range partition method.
    #
    # @param name [String, Symbol] The name of the partition.
    # @param options [Hash] The options to create the partition.
    # @yield [td] A TableDefinition object. This allows creating the table columns the same way
    #   as Rails's +create_table+ does.
    #
    # @see Tablature::Adapters::Postgres#create_range_partition
    def create_range_partition(name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_range_partition(name, options, &block)
    end

    # Creates a partition of a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#create_range_partition_of
    def create_range_partition_of(parent_table, options)
      if options[:range_start].nil? || options[:range_end].nil?
        raise ArgumentError, 'range_start and range_end must be defined'
      end

      Tablature.database.create_range_partition_of(parent_table, options)
    end
  end
end
