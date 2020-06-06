module Tablature
  module Adapters
    class Postgres
      # @api private
      module Quoting
        def quote_partition_key(key)
          return key.call.to_s if key.respond_to?(:call)
          # Don't bother quoting the key if it is already quoted (when loading the schema for
          # example).
          return key if key.to_s.include?("'") || key.to_s.include?('"')

          key.to_s.split('::').map(&method(:quote_column_name)).join('::')
        end

        def quote_collection(values)
          Array.wrap(values).map(&method(:quote)).join(',')
        end
      end
    end
  end
end
