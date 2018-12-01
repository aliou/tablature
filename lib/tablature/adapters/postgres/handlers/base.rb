require 'tablature/adapters/postgres/quoting'
require 'tablature/adapters/postgres/uuid'

module Tablature
  module Adapters
    class Postgres
      module Handlers
        class Base
          include Postgres::Quoting
          include Postgres::UUID

          protected

          def create_partition(table_name, id_options, table_options, &block)
            create_table(table_name, table_options) do |td|
              # TODO: Handle the id things here (depending on the postgres version)
              if id_options[:type] == :uuid
                td.column(
                  id_options[:column_name], id_options[:type], null: false, default: uuid_function
                )
              elsif id_options[:type]
                td.column(id_options[:column_name], id_options[:type], null: false)
              end

              yield(td) if block.present?
            end
          end

          def extract_primary_key!(options)
            type = options.fetch(:id, :bigserial)
            column_name = options.fetch(:primary_key, :id)

            raise ArgumentError, 'composite primary key not supported' if column_name.is_a?(Array)

            { type: type, column_name: column_name }
          end
        end
      end
    end
  end
end
