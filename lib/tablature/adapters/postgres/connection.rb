module Tablature
  module Adapters
    class Postgres
      # Decorates an ActiveRecord connection with methods that help determine
      # the connections capabilities.
      #
      # Every attempt is made to use the versions of these methods defined by
      # Rails where they are available and public before falling back to our own
      # implementations for older Rails versions.
      #
      # @api private
      class Connection < SimpleDelegator
        # True if the connection supports range partitions.
        #
        # @return [Boolean]
        def supports_range_partitions?
          postgresql_version >= 100_000
        end

        # True if the connection supports list partitions.
        #
        # @return [Boolean]
        def supports_list_partitions?
          postgresql_version >= 100_000
        end

        # True if the connection supports hash partitions.
        #
        # @return [Boolean]
        def supports_hash_partitions?
          # TODO: Check that this is the correct value.
          postgresql_version >= 110_000
        end

        # An integer representing the version of Postgres we're connected to.
        #
        # postgresql_version is public in Rails 5, but protected in earlier
        # versions.
        #
        # @return [Integer]
        def postgresql_version
          if undecorated_connection.respond_to?(:postgresql_version)
            super
          else
            undecorated_connection.send(:postgresql_version)
          end
        end

        private

        def undecorated_connection
          __getobj__
        end
      end
    end
  end
end
