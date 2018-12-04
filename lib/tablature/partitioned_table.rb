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
    attr_reader :name

    # The partitioning method of the table
    # @return [Symbol]
    attr_reader :partioning_method

    # The partitions of the table.
    # @return [Array]
    attr_reader :partitions

    # Returns a new instance of PartitionTable.
    #
    # @param name [String] The name of the view.
    # @param partioning_method [:symbol] One of :range, :list or :hash
    # @param partitions [Array] The partitions of the table.
    def initialize(name:, partioning_method:, partitions: [])
      @name = name
      @partioning_method = partioning_method
      @partitions = partitions
    end
  end
end
