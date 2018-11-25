module Tablature
  module Adapters
    class Postgres
      module Quoting
        # TODO: No docs, tests
        # TODO: delegate `quote_column_name` here ?
        def quote_partition_key(key)
          key.to_s.split('::').map(&method(:quote_column_name)).join('::')
        end
      end
    end
  end
end
