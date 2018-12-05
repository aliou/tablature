module Tablature
  # @api private
  module SchemaDumper
    def tables(stream)
      # Add partitions to the list of ignored tables.
      ActiveRecord::SchemaDumper.ignore_tables =
        (ActiveRecord::SchemaDumper.ignore_tables || []) + partitions

      super
    end

    private

    def dumpable_partitioned_tables
      Tablature.database.partitioned_tables
    end

    def partitions
      dumpable_partitioned_tables.flat_map(&:partitions)
    end
  end
end
