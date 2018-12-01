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
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include Tablature::Statements
    ActiveRecord::Migration::CommandRecorder.include Tablature::CommandRecorder
    ActiveRecord::SchemaDumper.prepend Tablature::SchemaDumper
    ActiveRecord::Base.prepend Tablature::Model
  end

  def self.database
    configuration.database
  end
end
