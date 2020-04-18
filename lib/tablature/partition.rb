module Tablature
  # The in-memory representation of a partition.
  #
  # **This object is used internally by adapters and the schema dumper and is
  # not intended to be used by application code. It is documented here for
  # use by adapter gems.**
  #
  # @api private
  class Partition
    attr_reader :name
    attr_reader :parent_table_name

    def initialize(name:, parent_table_name:, default_partition: false)
      @name = name
      @parent_table_name = parent_table_name
      @default_partition = default_partition
    end

    def default_partition?
      @default_partition
    end
  end
end
