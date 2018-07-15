require 'spec_helper'

module Tablature
  RSpec.describe Configuration do
    after { restore_default_config }

    it 'defaults the database adapter to postgres' do
      expect(Tablature.configuration.database).to be_a Adapters::Postgres
      expect(Tablature.database).to be_a Adapters::Postgres
    end

    it 'allows the database adapter to be set' do
      adapter = double('Tablature Adapter')

      Tablature.configure do |config|
        config.database = adapter
      end

      expect(Tablature.configuration.database).to eq adapter
      expect(Tablature.database).to eq adapter
    end

    def restore_default_config
      Tablature.configuration = Configuration.new
    end
  end
end
