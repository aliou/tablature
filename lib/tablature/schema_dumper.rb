module Tablature
  # @api private
  module SchemaDumper
    def tables(stream)
      # Add partitions to the list of ignored tables.
      ActiveRecord::SchemaDumper.ignore_tables =
        (ActiveRecord::SchemaDumper.ignore_tables || []) + partitions

      super
      partitioned_tables(stream)
    end

    def partitioned_tables(stream)
      return stream unless dumpable_partitioned_tables.any?

      stream.puts

      dumpable_partitioned_tables.each do |partitionned_table|
        dump_partioned_table(partitionned_table, stream)
      end

      stream
    end

    private

    def dump_partioned_table(partitioned_table, main_stream)
      # Call the original method to populate our custom stream
      stream = StringIO.new
      table(partitioned_table.name, stream)

      content = stream.tap(&:rewind).read
                      .gsub(
                        /create_table.*/,
                        "create_list_partition \"#{partitioned_table.name}\, partition_key: \"#{partitioned_table.partition_key}\" do"
                      )

      binding.pry

      # main_stream.print(content)

      main_stream
    end

    def dumpable_partitioned_tables
      Tablature.database.partitioned_tables.sort
    end

    def partitions
      dumpable_partitioned_tables.flat_map(&:partitions)
    end
  end
end
