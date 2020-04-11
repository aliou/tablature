module Tablature
  # The in-memory representation of a partitioned table definition.
  #
  # **This object is used internally by adapters and the schema dumper and is
  # not intended to be used by application code. It is documented here for
  # use by adapter gems.**
  #
  # @api extension
  class PartitionedTable
    # The name of the partitioned table
    # @return [String]
    # @api private
    attr_reader :name

    # TODO: Rename to partition_strategy

    # The partitioning method of the table
    # @return [Symbol]
    # @api private
    attr_reader :partitioning_method

    # The partitions of the table.
    # @return [Array]
    # @api private
    attr_reader :partitions

    # The partition key expression.
    # @return [String]
    # @api private
    attr_reader :partition_key

    # Returns a new instance of PartitionTable.
    #
    # @param name [String] The name of the view.
    # @param partitioning_method [:symbol] One of :range, :list or :hash
    # @param partitions [Array] The partitions of the table.
    # @param partition_key [String] The partition key expression.
    def initialize(name:, partitioning_method:, partitions: [], partition_key:)
      @name = name
      @partitioning_method = partitioning_method
      @partitions = partitions.map do |row|
        Tablature::Partition.new(
          name: row['partition_name'],
          parent_table_name: row['table_name']
        )
      end
      @partition_key = partition_key
    end
  end
end
