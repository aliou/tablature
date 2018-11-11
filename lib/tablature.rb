require 'tablature/adapters/postgres'
require 'tablature/configuration'
require 'tablature/partitioned_table'
require 'tablature/railtie'
require 'tablature/statements'
require 'tablature/version'

require 'active_record'

# Tablature adds methods to `ActiveRecord::Migration` to create and manage partitioned
# tables in Rails applications.
module Tablature
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include Tablature::Statements
  end

  def self.database
    configuration.database
  end
end
