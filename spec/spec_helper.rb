ENV['RAILS_ENV'] = 'test'
require 'database_cleaner'

require File.expand_path("../dummy/config/environment", __FILE__)

require 'bundler/setup'
require 'tablature'

RSpec.configure do |config|
  config.order = 'random'

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  DatabaseCleaner.strategy = :transaction

  config.around(:each, database: true) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  config.include ActiveSupport::Testing::Stream if defined? ActiveSupport::Testing::Stream
end
