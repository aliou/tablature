module Tablature
  # Methods that are made available in migrations.
  module Statements
    # Creates a partitioned table using the list partition method.
    #
    # @param table_name [String, Symbol] The name of the partition.
    # @param options [Hash] The options to create the partition.
    # @yield [td] A TableDefinition object. This allows creating the table columns the same way
    #   as Rails's +create_table+ does.
    # @see Tablature::Adapters::Postgres#create_list_partition
    def create_list_partition(table_name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_list_partition(table_name, options, &block)
    end

    # Creates a partition of a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#create_list_partition_of
    def create_list_partition_of(parent_table_name, options)
      if options[:values].blank? && options[:default].blank?
        raise ArgumentError, 'values or default must be defined'
      end

      Tablature.database.create_list_partition_of(parent_table_name, options)
    end

    # Attaches a partition to a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to attach the partition.
    #
    # @see Tablature::Adapters::Postgres#attach_to_list_partition
    def attach_to_list_partition(parent_table_name, options)
      raise ArgumentError, 'partition_name must be defined' if options[:partition_name]

      Tablature.database.attach_to_list_partition(parent_table_name, options)
    end

    # Detaches a partition from a parent.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#detach_from_list_partition
    def detach_from_list_partition(parent_table_name, options)
      raise ArgumentError, 'partition_name must be defined' if options[:partition_name]
      if options[:values].blank? && options[:default].blank?
        raise ArgumentError, 'values or default must be defined'
      end

      Tablature.database.attach_to_list_partition(parent_table_name, options)
    end

    # Creates a partitioned table using the range partition method.
    #
    # @param table_name [String, Symbol] The name of the partition.
    # @param options [Hash] The options to create the partition.
    # @yield [td] A TableDefinition object. This allows creating the table columns the same way
    #   as Rails's +create_table+ does.
    #
    # @see Tablature::Adapters::Postgres#create_range_partition
    def create_range_partition(table_name, options, &block)
      raise ArgumentError, 'partition_key must be defined' if options[:partition_key].nil?

      Tablature.database.create_range_partition(table_name, options, &block)
    end

    # Creates a partition of a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#create_range_partition_of
    def create_range_partition_of(parent_table_name, options)
      if (options[:range_start].nil? || options[:range_end].nil?) && options[:default].blank?
        raise ArgumentError, 'range_start and range_end or default must be defined'
      end

      Tablature.database.create_range_partition_of(parent_table_name, options)
    end

    # Attaches a partition to a parent by specifying the key values appearing in the partition.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to create the partition.
    #
    # @see Tablature::Adapters::Postgres#attach_to_range_partition
    def attach_to_range_partition(parent_table_name, options)
      raise ArgumentError, 'partition_name must be defined' if options[:name]
      if (options[:range_start].nil? || options[:range_end].nil?) && options[:default].blank?
        raise ArgumentError, 'range_start and range_end or default must be defined'
      end

      Tablature.database.attach_to_range_partition(parent_table_name, options)
    end

    # Detaches a partition from a parent.
    #
    # @param parent_table_name [String, Symbol] The name of the parent table.
    # @param [Hash] options The options to detach the partition.
    #
    # @see Tablature::Adapters::Postgres#detach_from_range_partition
    def detach_from_range_partition(parent_table_name, options)
      raise ArgumentError, 'partition_name must be defined' if options[:name]

      Tablature.database.detach_from_range_partition(parent_table_name, options)
    end
  end
end
