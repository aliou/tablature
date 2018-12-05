require 'spec_helper'

RSpec.describe Tablature::Adapters::Postgres::Connection do
  describe '#supports_range_partitions?' do
    it 'is true if the postgres version is at least 10.0' do
      base_connection = double('Connection', postgresql_version: 100_000)
      connection = described_class.new(base_connection)

      expect(connection.supports_range_partitions?).to eq(true)
    end

    it 'is false if the postgres version is less than 10.0' do
      base_connection = double('Connection', postgresql_version: 99_999)
      connection = described_class.new(base_connection)

      expect(connection.supports_range_partitions?).to eq(false)
    end
  end

  describe '#supports_list_partitions?' do
    it 'is true if the postgres version is at least 10.0' do
      base_connection = double('Connection', postgresql_version: 100_000)
      connection = described_class.new(base_connection)

      expect(connection.supports_list_partitions?).to eq(true)
    end

    it 'is false if the postgres version is less than 10.0' do
      base_connection = double('Connection', postgresql_version: 99_999)
      connection = described_class.new(base_connection)

      expect(connection.supports_list_partitions?).to eq(false)
    end
  end

  describe '#supports_hash_partitions?' do
    it 'is true if the postgres version is at least 11.0' do
      base_connection = double('Connection', postgresql_version: 110_000)
      connection = described_class.new(base_connection)

      expect(connection.supports_list_partitions?).to eq(true)
    end

    it 'is false if the postgres version is less than 11.0' do
      base_connection = double('Connection', postgresql_version: 109_999)
      connection = described_class.new(base_connection)

      expect(connection.supports_hash_partitions?).to eq(false)
    end
  end

  describe '#postgresql_version' do
    it 'uses the public method on the provided connection if defined' do
      base_connection = Class.new do
        def postgresql_version
          123
        end
      end

      connection = described_class.new(base_connection.new)

      expect(connection.postgresql_version).to eq 123
    end

    it 'uses the protected method if the underlying method is not public' do
      base_connection =
        Class.new do
          protected

          def postgresql_version
            123
          end
        end

      connection = described_class.new(base_connection.new)

      expect(connection.postgresql_version).to eq 123
    end
  end
end
