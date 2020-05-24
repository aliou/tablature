# TODO: Try to replace the creation methods in the main stream instead of dumping the partitioned
# tables at the end of the schema.
module Tablature
  # @api private
  module SchemaDumper
    def tables(stream)
      # Add partitions to the list of ignored tables.
      ActiveRecord::SchemaDumper.ignore_tables =
        (ActiveRecord::SchemaDumper.ignore_tables || []) +
        dumpable_partitioned_tables.map(&:name) +
        partitions

      super

      partitioned_tables(stream)
    end

    def partitioned_tables(stream)
      stream.puts if dumpable_partitioned_tables.any?

      dumpable_partitioned_tables.each do |partitioned_table|
        dump_partitioned_table(partitioned_table, stream)
        dump_partition_indexes(partitioned_table, stream)
      end
    end

    private

    attr_reader :connection
    delegate :quote_table_name, :quote, to: :connection

    PARTITION_METHOD_MAP = {
      list: 'create_list_partition',
      range: 'create_range_partition'
    }.freeze
    private_constant :PARTITION_METHOD_MAP

    def dump_partitioned_table(partitioned_table, main_stream)
      # Pretend the partitioned table is a regular table and dump it in an alternate stream.
      stream = StringIO.new
      table(partitioned_table.name, stream)

      # Fetch the creation method for handled partitioning methods, otherwise comment that the
      # partitioning method is not handled.
      creation_method = PARTITION_METHOD_MAP.fetch(partitioned_table.partitioning_strategy) do
        main_stream.puts <<~MESSAGE
          # Invalid partitioning strategy "#{partitioned_table.partitioning_strategy}" for partitioned table "#{partitioned_table.name}".
        MESSAGE

        return
      end

      # Replace the table creation line with our own line using the partition creation method.
      content = stream.tap(&:rewind).read.gsub(
        /create_table.*/,
        <<~CONTENT.strip
          #{creation_method} #{quote_table_name(partitioned_table.name)}, partition_key: #{quote(partitioned_table.partition_key)} do |t|
        CONTENT
      )

      main_stream.puts(content)
    end

    # Delegate to the adapter the dumping of indexes.
    def dump_partition_indexes(partitioned_table, stream)
      return unless Tablature.database.respond_to?(:indexes_on)

      indexes = Tablature.database.indexes_on(partitioned_table.name)
      return if indexes.empty?

      add_index_statements = indexes.map do |index|
        table_name = remove_prefix_and_suffix(index.table).inspect
        "  add_index #{([table_name] + index_parts(index)).join(', ')}"
      end

      stream.puts add_index_statements.sort.join("\n")
      stream.puts
    end

    def dumpable_partitioned_tables
      Tablature.database.partitioned_tables.sort
    end

    def partitions
      dumpable_partitioned_tables.flat_map { |t| t.partitions.map(&:name) }
    end
  end
end
