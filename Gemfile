gemspec

gem 'pry'

rails_version = ENV.fetch("RAILS_VERSION", "6.0")

if rails_version == "master"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}.0"
end

gem "rails", rails_constraint
gem 'database_cleaner'
