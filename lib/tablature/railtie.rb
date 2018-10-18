require 'rails/railtie'

module Tablature
  # Automatically initializes Tablature in the context of a Rails application when
  # ActiveRecord is loaded.
  #
  # @see Tablature.load
  class Railtie < Rails::Railtie
    initializer 'tablature.load' do
      ActiveSupport.on_load :active_record do
        Tablature.load
      end
    end
  end
end
