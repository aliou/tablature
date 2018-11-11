module Tablature
  module Adapters
    class Postgres
      # Fetches the defined partitioned tables from the postgres connection.
      # @api private
      class PartitionedTables
        def initialize(connection)
          @connection = connection
        end

        def all
          partitioned_tables_from_postgres.map(&method(:to_tablature_table))
        end

        private

        attr_reader :connection

        def partitioned_tables_from_postgres
          connection.execute(<<-SQL)
            SELECT
              c.oid,
              c.relname AS table_name,
              p.partstrat AS type
            FROM pg_class c
              INNER JOIN pg_partitioned_table p ON c.oid = p.partrelid
              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE
              p.partstrat IN ('l', 'r', 'h')
              AND c.relname NOT IN (SELECT extname FROM pg_extension)
              AND n.nspname = ANY (current_schemas(false))
            ORDER BY c.oid
          SQL
        end

        TYPE_MAP = {
          'l' => :list,
          'r' => :range,
          'h' => :hash
        }.freeze
        private_constant :TYPE_MAP

        def to_tablature_table(result)
          name = result['table_name']
          type = TYPE_MAP.fetch(result['type'])
          Tablature::PartitionedTable.new(name: name, type: type)
        end
      end
    end
  end
end
