require 'spec_helper'

RSpec.describe Tablature::Model::PartitionMethods, :database do
  describe '#tablature_partition' do
    context 'without a custom name' do
      it 'returns the tablature partition' do
        class Event < ActiveRecord::Base
          extend Tablature::Model::PartitionMethods
        end
        Event.send(:setup_partition, 'events')
        connection = ActiveRecord::Base.connection
        connection.execute <<-SQL
          CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
        SQL

        tablature_partition = Event.tablature_partition
        expect(tablature_partition).to be_a Tablature::PartitionedTable
        expect(tablature_partition.name).to eq('events')
      end
    end

    context 'with a custom name' do
      it 'returns the tablature partition' do
        class Event < ActiveRecord::Base
          extend Tablature::Model::PartitionMethods
        end
        Event.send(:setup_partition, 'events_2019')
        connection = ActiveRecord::Base.connection
        connection.execute <<-SQL
          CREATE TABLE "events_2019" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
        SQL

        tablature_partition = Event.tablature_partition
        expect(tablature_partition).to be_a Tablature::PartitionedTable
        expect(tablature_partition.name).to eq('events_2019')
      end
    end

    context 'when there are no partitioned table' do
      it 'raises an error' do
        class Event < ActiveRecord::Base; end

        expect { Event.tablature_partition }.to raise_error(Tablature::MissingPartition)
      end
    end
  end

  describe 'partitioned?' do
    it 'is true when partitioned' do
      class Event < ActiveRecord::Base
        extend Tablature::Model::PartitionMethods
      end
      Event.send(:setup_partition, 'events')
      connection = ActiveRecord::Base.connection
      connection.execute <<-SQL
        CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
      SQL

      expect(Event.partitioned?).to be true
    end

    it 'is false when not partitioned' do
      class Event < ActiveRecord::Base
        extend Tablature::Model::PartitionMethods
      end

      expect(Event.partitioned?).to be false
    end
  end

  describe '#partitions' do
    it 'delegates to the partition table object' do
      class Event < ActiveRecord::Base
        extend Tablature::Model::PartitionMethods
      end
      tablature_partition_double = double(Tablature::PartitionedTable)
      allow(Event).to receive(:tablature_partition).and_return(tablature_partition_double)

      expect(tablature_partition_double).to receive(:partitions)
      Event.partitions
    end
  end

  describe '#partition_key' do
    it 'delegates to the partition table object' do
      class Event < ActiveRecord::Base
        list_partition
      end
      tablature_partition_double = double(Tablature::PartitionedTable)
      allow(Event).to receive(:tablature_partition).and_return(tablature_partition_double)

      expect(tablature_partition_double).to receive(:partition_key)
      Event.partition_key
    end
  end

  describe '#partitioning_method' do
    it 'delegates to the partition table object' do
      class Event < ActiveRecord::Base
        extend Tablature::Model::PartitionMethods
      end
      tablature_partition_double = double(Tablature::PartitionedTable)
      allow(Event).to receive(:tablature_partition).and_return(tablature_partition_double)

      expect(tablature_partition_double).to receive(:partitioning_method)
      Event.partitioning_method
    end
  end
end
