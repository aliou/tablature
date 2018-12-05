module Tablature
  module Adapters
    class Postgres
      # @api private
      module UUID
        def uuid_function
          try(:supports_pgcrypto_uuid?) ? 'gen_random_uuid()' : 'uuid_generate_v4()'
        end
      end
    end
  end
end
