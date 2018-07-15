require 'tablature/adapters/postgres'
require 'tablature/configuration'
require 'tablature/version'

require 'active_record'

# Tablature adds methods to `ActiveRecord::Migration` to create and manage database
# views in Rails applications.
module Tablature
  def self.load
  end

  def self.database
    configuration.database
  end
end
