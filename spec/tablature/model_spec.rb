require 'spec_helper'

RSpec.describe Tablature::Model, :database do
  let(:model_class) { Class.new }

  describe '.included' do
    it 'extends the class with the class methods' do
      expect(model_class).to receive(:extend).with(described_class::ClassMethods)
      model_class.include(described_class)
    end
  end

  describe Tablature::Model::ClassMethods do
    describe '#tablature_partition' do
      # after(:each) do
      #   Event.remove_instance_variable(:@tablature_partition)
      # end

      context 'without a custom name' do
        let(:model) do
          Class.new(ActiveRecord::Base) do
            include Tablature::Model
            self.table_name = 'events'
          end
        end

        it 'returns the tablature partition' do
          model.send(:setup_partition, 'events')
          connection = ActiveRecord::Base.connection
          connection.execute <<-SQL
            CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
          SQL

          tablature_partition = model.tablature_partition
          expect(tablature_partition).to be_a Tablature::PartitionedTable
          expect(tablature_partition.name).to eq('events')
        end
      end

      context 'with a custom name' do
        let(:model) do
          Class.new(ActiveRecord::Base) do
            include Tablature::Model
            self.table_name = 'events'
          end
        end

        it 'returns the tablature partition' do
          model.send(:setup_partition, 'events_2019')
          connection = ActiveRecord::Base.connection
          connection.execute <<-SQL
            CREATE TABLE "events_2019" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
          SQL

          tablature_partition = model.tablature_partition
          expect(tablature_partition).to be_a Tablature::PartitionedTable
          expect(tablature_partition.name).to eq('events_2019')
        end
      end

      context 'when there are no partitioned table' do
        let(:model) do
          Class.new(ActiveRecord::Base) do
            include Tablature::Model
            self.table_name = 'events'
          end
        end

        it 'raises an error' do
          expect { model.tablature_partition }.to raise_error(Tablature::MissingPartition)
        end
      end
    end

    describe 'partitioned?' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
          self.table_name = 'events'
        end
      end

      it 'is true when partitioned' do
        model.send(:setup_partition, 'events')
        connection = ActiveRecord::Base.connection
        connection.execute <<-SQL
          CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
        SQL

        expect(model.partitioned?).to be true
      end

      it 'is false when not partitioned' do
        expect(model.partitioned?).to be false
      end
    end

    describe '#partitions' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
          self.table_name = 'events'
        end
      end

      it 'delegates to the partition table object' do
        # class Event < ActiveRecord::Base
        #   include Tablature::Model
        # end
        tablature_partition_double = double(Tablature::PartitionedTable)
        allow(model).to receive(:tablature_partition).and_return(tablature_partition_double)

        expect(tablature_partition_double).to receive(:partitions)
        model.partitions
      end
    end

    describe '#partition_key' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
        end
      end

      it 'delegates to the partition table object' do
        tablature_partition_double = double(Tablature::PartitionedTable)
        allow(model).to receive(:tablature_partition).and_return(tablature_partition_double)

        expect(tablature_partition_double).to receive(:partition_key)
        model.partition_key
      end
    end

    describe '#partitioning_strategy' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
        end
      end

      it 'delegates to the partition table object' do
        tablature_partition_double = double(Tablature::PartitionedTable)
        allow(model).to receive(:tablature_partition).and_return(tablature_partition_double)

        expect(tablature_partition_double).to receive(:partitioning_strategy)
        model.partitioning_strategy
      end
    end

    describe '.list_partition' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
          self.table_name = 'events'
        end
      end

      it 'sets up the partition name' do
        model.list_partition

        expect(model.partition_name).to eq('events')
      end

      it 'extends the model with list partition methods' do
        expect(model).to receive(:extend).with(Tablature::Model::ListPartitionMethods)
        model.list_partition
      end
    end

    describe '.range_partition' do
      let(:model) do
        Class.new(ActiveRecord::Base) do
          include Tablature::Model
          self.table_name = 'events'
        end
      end

      it 'sets up the partition name' do
        model.range_partition

        expect(model.partition_name).to eq('events')
      end

      it 'extends the model with range partition methods' do
        expect(model).to receive(:extend).with(Tablature::Model::RangePartitionMethods)
        model.range_partition
      end
    end
  end

  describe Tablature::Model::ListPartitionMethods do
    describe '#create_list_partition' do
      let(:model) do
        Class.new do
          include Tablature::Model
          list_partition :events
        end
      end

      it 'delegates the list partition creation to the adapter' do
        options = { values: (0..10).to_a }

        partition_stub = double(Tablature::PartitionedTable, name: 'events')
        allow(model).to receive(:tablature_partition).and_return(partition_stub)

        expect(Tablature.database)
          .to receive(:create_list_partition_of)
          .with('events', options)

        model.create_list_partition(options)
      end
    end
  end

  describe Tablature::Model::RangePartitionMethods do
    describe '#create_range_partition' do
      let(:model) do
        Class.new do
          include Tablature::Model
          range_partition :events
        end
      end

      it 'delegates the list partition creation to the adapter' do
        options = { range_start: 0, range_end: 10 }

        partition_stub = double(Tablature::PartitionedTable, name: 'events')
        allow(model).to receive(:tablature_partition).and_return(partition_stub)

        expect(Tablature.database)
          .to receive(:create_range_partition_of)
          .with('events', options)

        model.create_range_partition(options)
      end
    end
  end
end
