require File.expand_path('boot', __dir__)

# Pick the frameworks you want:
require 'active_record/railtie'

Bundler.require(*Rails.groups)
require 'tablature'

module Dummy
  class Application < Rails::Application
    config.cache_classes = true
    config.eager_load = false
    config.active_support.deprecation = :stderr
  end
end
