module Tablature
  module Adapters
    class Postgres
      module UUID
        # TODO: No docs, tests
        def uuid_function
          try(:supports_pgcrypto_uuid?) ? 'gen_random_uuid()' : 'uuid_generate_v4()'
        end
      end
    end
  end
end
