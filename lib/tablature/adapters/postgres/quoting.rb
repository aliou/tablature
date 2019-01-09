module Tablature
  module Adapters
    class Postgres
      # @api private
      module Quoting
        def quote_partition_key(key)
          if key.respond_to?(:call)
            key.call.to_s
          else
            key.to_s.split('::').map(&method(:quote_column_name)).join('::')
          end
        end

        def quote_collection(values)
          Array.wrap(values).map(&method(:quote)).join(',')
        end
      end
    end
  end
end
