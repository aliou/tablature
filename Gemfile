source 'https://rubygems.org'
gemspec

gem 'pry'
gem 'rubocop'

rails_version = ENV.fetch('RAILS_VERSION', '6.0')

rails_constraint = rails_version == 'master' ? { github: 'rails/rails' } : "~> #{rails_version}.0"

gem 'rails', rails_constraint
