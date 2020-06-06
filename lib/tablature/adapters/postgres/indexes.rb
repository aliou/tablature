module Tablature
  module Adapters
    class Postgres
      # Fetches indexes on objects from the Postgres connection.
      #
      # @api private
      class Indexes
        def initialize(connection)
          @connection = connection
        end

        def on(name)
          indexes_on(name).map(&method(:index_from_database))
        end

        private

        attr_reader :connection

        def indexes_on(name)
          connection.exec_query(<<-SQL, 'SCHEMA').to_a
            SELECT DISTINCT
              i.relname AS index_name,
              d.indisunique AS is_unique,
              d.indkey AS index_keys,
              pg_get_indexdef(d.indexrelid) AS definition,
              t.oid AS oid,
              pg_catalog.obj_description(i.oid, 'pg_class') AS comment,
              t.relname AS table_name,
              string_agg(a.attname, ',') OVER (PARTITION BY i.relname) AS column_names
            FROM pg_class t
            INNER JOIN pg_index d ON t.oid = d.indrelid
            INNER JOIN pg_class i ON d.indexrelid = i.oid
            LEFT JOIN pg_namespace n ON n.oid = i.relnamespace
            LEFT JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY (d.indkey)
            WHERE i.relkind = 'I'
              AND d.indisprimary = 'f'
              AND t.relname = '#{name}'
              AND n.nspname = ANY (current_schemas(false))
            ORDER BY i.relname
          SQL
        end

        def index_from_database(result)
          result = format_result(result)

          if rails_version >= Gem::Version.new('5.2')
            ActiveRecord::ConnectionAdapters::IndexDefinition.new(
              result['table_name'], result['index_name'], result['is_unique'], result['columns'],
              lengths: {}, orders: result['orders'], opclasses: result['opclasses'],
              where: result['where'], using: result['using'].to_sym,
              comment: result['comment'].presence
            )
          elsif rails_version >= Gem::Version.new('5.0')
            ActiveRecord::ConnectionAdapters::IndexDefinition.new(
              result['table_name'], result['index_name'], result['is_unique'], result['columns'],
              {}, result['orders'], result['where'], nil, result['using'].to_sym,
              result['comment'].presence
            )
          end
        end

        INDEX_PATTERN = /(?<column>\w+)"?\s?(?<opclass>\w+_ops)?\s?(?<desc>DESC)?\s?(?<nulls>NULLS (?:FIRST|LAST))?/.freeze
        private_constant :INDEX_PATTERN

        USING_PATTERN = / USING (\w+?) \((.+?)\)(?: WHERE (.+))?\z/m.freeze
        private_constant :USING_PATTERN

        def format_result(result)
          result['index_keys'] = result['index_keys'].split.map(&:to_i)
          result['column_names'] = result['column_names'].split(',')
          result['using'], expressions, result['where'] = result['definition'].scan(USING_PATTERN).flatten
          result['columns'] = result['index_keys'].include?(0) ? expressions : result['column_names']

          result['orders'] = {}
          result['opclasses'] = {}

          expressions.scan(INDEX_PATTERN).each do |column, opclass, desc, nulls|
            result['opclasses'][column] = opclass.to_sym if opclass
            if nulls
              result['orders'][column] = [desc, nulls].compact.join(' ')
            elsif desc
              result['orders'][column] = :desc
            end
          end

          result
        end

        def rails_version
          @rails_version ||= Gem::Version.new(Rails.version)
        end
      end
    end
  end
end
