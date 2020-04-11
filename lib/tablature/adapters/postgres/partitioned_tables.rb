module Tablature
  module Adapters
    class Postgres
      # Fetches the defined partitioned tables from the postgres connection.
      # @api private
      class PartitionedTables
        include Enumerable

        def initialize(connection)
          @connection = connection
        end

        # All of the partitioned table that this connection has defined.
        #
        # @return [Array<Tablature::PartitionedTable>]
        def all
          partitions.group_by { |row| row['table_name'] }.map(&method(:to_tablature_table))
        end

        def each(&block)
          all.each(&block)
        end

        private

        attr_reader :connection

        def partitions
          connection.execute(<<-SQL)
            SELECT
              c.oid,
              c.relname AS table_name,
              p.partstrat AS type,
              (i.inhrelid::REGCLASS)::TEXT AS partition_name,
              pg_get_partkeydef(c.oid) AS partition_key_definition
            FROM pg_class c
              INNER JOIN pg_partitioned_table p ON c.oid = p.partrelid
              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
              FULL OUTER JOIN pg_catalog.pg_inherits i ON c.oid = i.inhparent
            WHERE
              p.partstrat IN ('l', 'r', 'h')
              AND c.relname NOT IN (SELECT extname FROM pg_extension)
              AND n.nspname = ANY (current_schemas(false))
            ORDER BY c.oid
          SQL
        end

        METHOD_MAP = {
          'l' => :list,
          'r' => :range,
          'h' => :hash
        }.freeze
        private_constant :METHOD_MAP

        def to_tablature_table(table_name, rows)
          result = rows.first
          partitioning_method = METHOD_MAP.fetch(result['type'])
          partitions = rows.map { |row| row['partition_name'] }.compact.map(&method(:unquote))
          # This is very fragile code. This makes the assumption that:
          # - Postgres will always have a function `pg_get_partkeydef` that returns the partition
          # method with the partition key
          # - Postgres will never have a partition method with two words in its name.
          _, partition_key = result['partition_key_definition'].split(' ', 2)

          Tablature::PartitionedTable.new(
            name: table_name, partitioning_method: partitioning_method,
            partitions: partitions, partition_key: partition_key
          )
        end

        # Taken from Rails's codebase.
        def unquote(part)
          return part if part.blank?

          part.start_with?('"') ? part[1..-2] : part
        end
      end
    end
  end
end
