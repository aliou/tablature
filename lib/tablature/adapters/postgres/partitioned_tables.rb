module Tablature
  module Adapters
    class Postgres
      # Fetches the defined partitioned tables from the postgres connection.
      # @api private
      class PartitionedTables
        def initialize(connection)
          @connection = connection
        end

        # All of the partitioned table that this connection has defined.
        #
        # @return [Array<Tablature::PartitionedTable>]
        def all
          partitions.group_by { |row| row['table_name'] }.map(&method(:to_tablature_table))
        end

        private

        attr_reader :connection

        # rubocop:disable Metrics/MethodLength
        def partitions
          result = connection.exec_query(<<-SQL, 'SCHEMA')
            SELECT
              c.oid,
              i.inhrelid,
              c.relname AS table_name,
              p.partstrat AS strategy,
              (i.inhrelid::REGCLASS)::TEXT AS partition_name,
              #{connection.supports_default_partitions? ? 'i.inhrelid = p.partdefid AS is_default_partition,' : ''}
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

          result.to_a
        end
        # rubocop:enable Metrics/MethodLength

        STRATEGY_MAP = {
          'l' => :list,
          'r' => :range,
          'h' => :hash
        }.freeze
        private_constant :STRATEGY_MAP

        def to_tablature_table(table_name, rows)
          result = rows.first
          partitioning_strategy = STRATEGY_MAP.fetch(result['strategy'])
          # This is very fragile code. This makes the assumption that:
          # - Postgres will always have a function `pg_get_partkeydef` that returns the partition
          # strategy with the partition key
          # - Postgres will never have a partition strategy with two words in its name.
          _, partition_key = result['partition_key_definition'].split(' ', 2)

          Tablature::PartitionedTable.new(
            name: table_name, partitioning_strategy: partitioning_strategy,
            partitions: rows, partition_key: partition_key
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
