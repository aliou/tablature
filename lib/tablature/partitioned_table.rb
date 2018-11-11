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

    # The type of the partitioned table
    # @return [Symbol]
    attr_reader :type

    # Returns a new instance of View.
    #
    # @param name [String] The name of the view.
    # @param type [:symbol] One of :range, :list or :hash
    def initialize(name:, type:)
      @name = name
      @type = type
    end

    # @api private
    def ==(other)
      name == other.name && type == other.type
    end
  end
end
