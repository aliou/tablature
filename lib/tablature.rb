require 'tablature/adapters/postgres'
require 'tablature/command_recorder'
require 'tablature/configuration'
require 'tablature/model'
require 'tablature/partitioned_table'
require 'tablature/railtie'
require 'tablature/schema_dumper'
require 'tablature/statements'
require 'tablature/version'

require 'active_record'

# Tablature adds methods to `ActiveRecord::Migration` to create and manage partitioned
# tables in Rails applications.
module Tablature
  # Hooks Tablature into Rails.
  #
  # Enables tablature migration methods.
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include Tablature::Statements
    ActiveRecord::Migration::CommandRecorder.include Tablature::CommandRecorder
    ActiveRecord::SchemaDumper.prepend Tablature::SchemaDumper
    ActiveRecord::Base.include Tablature::Model
  end

  # The current database adapter used by Tablature.
  #
  # This defaults to {Adapters::Postgres} by can be overriden via {Configuration}.
  def self.database
    configuration.database
  end

  class MissingPartition < StandardError
    def initialize
      super('Missing partition')
    end
  end
end
