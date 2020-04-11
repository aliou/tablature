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
    it 'raises if the list values and the default flag are missing' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      expect { adapter.create_list_partition_of('events', values: nil) }
        .to raise_error described_class::MissingListPartitionValuesError
    end

    it 'raises if default partitions are not supported' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      # TODO: Find a way to mock `supports_default_partitions?` instead of the postgres version.
      connection = double('Connection', postgresql_version: 0)
      connectable = double('Connectable', connection: connection)
      adapter = described_class.new(connectable)

      expect { adapter.create_list_partition_of('events', default: true) }
        .to raise_error described_class::DefaultPartitionNotSupportedError
    end

    it 'creates the partition' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', values: [1, 2, 3], name: 'events_1')
      partitioned_table = adapter.partitioned_tables.first

      expect(partitioned_table.partitions.map(&:name)).to include('events_1')
    end
  end

  describe '#attach_to_list_partition' do
    it 'raises if the list values and the default flag are missing' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', name: 'events_a', values: [1, 2])
      adapter.detach_from_list_partition('events', name: 'events_a')

      expect { adapter.attach_to_list_partition('events', name: 'events_a') }
        .to raise_error described_class::MissingListPartitionValuesError
    end

    it 'raises if the name is missing' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', name: 'events_a', values: [1, 2])
      adapter.detach_from_list_partition('events', name: 'events_a')

      expect { adapter.attach_to_list_partition('events', values: [1, 2]) }
        .to raise_error described_class::MissingPartitionName
    end

    it 'attaches the partition' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', name: 'events_a', values: [1, 2])
      adapter.detach_from_list_partition('events', name: 'events_a')

      adapter.attach_to_list_partition('events', name: 'events_a', values: [1, 2])
      partitioned_table = adapter.partitioned_tables.find { |t| t.name == 'events' }

      expect(partitioned_table.partitions.map(&:name)).to include('events_a')
    end
  end

  describe '#detach_from_list_partition' do
    it 'raises if the name is missing' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', name: 'events_a', values: [1, 2])

      expect { adapter.detach_from_list_partition('events', {}) }
        .to raise_error described_class::MissingPartitionName
    end

    it 'detaches the partition' do
      adapter = described_class.new
      adapter.create_list_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_list_partition_of('events', name: 'events_a', values: [1, 2])
      adapter.detach_from_list_partition('events', name: 'events_a')

      partitioned_table = adapter.partitioned_tables.find { |t| t.name == 'events' }
      expect(partitioned_table.partitions.map(&:name)).to_not include('events_a')
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

  describe '#create_range_partition_of' do
    it 'raises if the range bounds are missing' do
      adapter = described_class.new
      adapter.create_range_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      expect { adapter.create_range_partition_of('events', range_start: nil) }
        .to raise_error described_class::MissingRangePartitionBoundsError
    end

    it 'raises if default partitions are not supported' do
      adapter = described_class.new
      adapter.create_range_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      # TODO: Find a way to mock `supports_default_partitions?` instead of the postgres version.
      connection = double('Connection', postgresql_version: 0)
      connectable = double('Connectable', connection: connection)
      adapter = described_class.new(connectable)

      expect { adapter.create_range_partition_of('events', default: true) }
        .to raise_error described_class::DefaultPartitionNotSupportedError
    end

    it 'creates the partition' do
      adapter = described_class.new
      adapter.create_range_partition 'events', partition_key: 'event_id' do |t|
        t.integer :event_id, null: false
      end

      adapter.create_range_partition_of('events', range_start: 0, range_end: 10, name: 'events_1')
      partitioned_table = adapter.partitioned_tables.first

      expect(partitioned_table.partitions.map(&:name)).to include('events_1')
    end
  end
end
