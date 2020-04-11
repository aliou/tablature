require_relative 'base'

module Tablature
  module Adapters
    class Postgres
      module Handlers
        # @api private
        class List < Base
          def initialize(connection)
            @connection = connection
          end

          def create_list_partition(table_name, options, &block)
            raise_unless_list_partition_supported

            # Postgres 10 does not handle indexes and therefore primary keys.
            # Therefore we manually create an `id` column.
            # TODO: Either make the library Postgres 11 only, or two code paths between Postgres 10
            # and Postgres 11.
            modified_options = options.except(:id, :primary_key, :partition_key)
            id_options = extract_primary_key!(options.slice(:id, :primary_key))
            partition_key = options.fetch(:partition_key)

            modified_options[:id]      = false
            modified_options[:options] = "PARTITION BY LIST (#{quote_partition_key(partition_key)})"

            create_partition(table_name, id_options, modified_options, &block)
          end

          def create_list_partition_of(parent_table, options)
            values = options.fetch(:values, [])
            raise MissingListPartitionValuesError if values.blank?

            name = options.fetch(:name, partition_name(parent_table, values))
            # TODO: Call `create_table` here instead of running the query.
            # TODO: Pass the options to `create_table` to allow further configuration of the table,
            # e.g. sub-partitioning the table.
            query = <<~SQL.strip
              CREATE TABLE #{quote_table_name(name)} PARTITION OF #{quote_table_name(parent_table)}
              FOR VALUES IN (#{quote_collection(values)})
            SQL

            execute(query)
          end

          def attach_to_list_partition(parent_table, options)
            values = options.fetch(:values, [])
            as_default = options.fetch(:default, false)
            raise MissingListPartitionValuesError if values.blank? && !as_default

            name = options.fetch(:name) { raise MissingPartitionName }
            query =
              if as_default
                <<~SQL.strip
                  ALTER TABLE #{quote_table_name(parent_table)}
                  ATTACH PARTITION #{quote_table_name(name)} DEFAULT
                SQL
              else
                <<~SQL.strip
                  ALTER TABLE #{quote_table_name(parent_table)}
                  ATTACH PARTITION #{quote_table_name(name)}
                  FOR VALUES IN (#{quote_collection(values)})
                SQL
              end

            execute(query)
          end

          def detach_from_list_partition(parent_table, options)
            name = options.fetch(:name) { raise MissingPartitionName }
            query = <<~SQL.strip
              ALTER TABLE #{quote_table_name(parent_table)}
              DETACH PARTITION #{quote_table_name(name)}
            SQL

            execute(query)
          end

          private

          attr_reader :connection

          delegate :execute, :quote, :quote_column_name, :quote_table_name, :create_table,
                   to: :connection

          def raise_unless_list_partition_supported
            raise ListPartitionsNotSupportedError unless connection.supports_list_partitions?
          end

          # TODO: Better ?
          def partition_name(parent_table, values)
            key = values.inspect
            "#{parent_table}_#{Digest::MD5.hexdigest(key)[0..6]}"
          end
        end
      end
    end
  end
end
