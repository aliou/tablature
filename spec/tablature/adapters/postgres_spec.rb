require 'spec_helper'

RSpec.describe Tablature::Adapters::Postgres, :database do
  describe '#create_list_partition' do
    it 'raises if the databases does not support list partitions' do
      # TODO: Find a way to mock `supports_list_partitions?` instead of the postgres version.
      connection = double('Connection', postgresql_version: 0)
      connectable = double('Connectable', connection: connection)
      adapter = described_class.new(connectable)

      expect { adapter.create_list_partition('events', partition_key: 'id') }
        .to raise_error described_class::ListPartitionsNotSupportedError
    end

    it 'creates a list partition' do
      adapter = described_class.new

      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      expect(adapter.partitioned_tables.map(&:name)).to include('events')
    end
  end

  describe '#create_list_partition_of' do
    it 'raises if the list values are missing' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      expect { adapter.create_list_partition_of('events', values: nil) }
        .to raise_error described_class::MissingListPartitionValuesError
    end
  end

  describe '#create_range_partition' do
    it 'raises if the databases does not support range partitions' do
      # TODO: Find a way to mock `supports_range_partitions?` instead of the postgres version.
      connection = double('Connection', postgresql_version: 0)
      connectable = double('Connectable', connection: connection)
      adapter = described_class.new(connectable)

      expect { adapter.create_range_partition('events', partition_key: 'id') }
        .to raise_error described_class::RangePartitionsNotSupportedError
    end

    it 'creates a range partition' do
      adapter = described_class.new

      adapter.create_range_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      expect(adapter.partitioned_tables.map(&:name)).to include('events')
    end
  end
end
