require 'spec_helper'

RSpec.describe Tablature::Model do
  let(:model_class) { Class.new }

  describe '.included' do
    it 'extends the class with the class methods' do
      expect(model_class).to receive(:extend).with(described_class::ClassMethods)
      model_class.include(described_class)
    end
  end

  describe Tablature::Model::ClassMethods do
    describe '.list_partition' do
      let(:model) do
        Class.new do
          extend Tablature::Model::ClassMethods

          def self.table_name
            'events'
          end
        end
      end

      it 'sets up the partition name' do
        model.list_partition

        expect(model.partition_name).to eq('events')
      end

      it 'extend the partition methods and list partition methods' do
        expect(model).to receive(:extend).with(Tablature::Model::PartitionMethods)
        expect(model).to receive(:extend).with(Tablature::Model::ListPartitionMethods)
        model.list_partition
      end
    end

    describe '.range_partition' do
      let(:model) do
        Class.new do
          extend Tablature::Model::ClassMethods

          def self.table_name
            'events'
          end
        end
      end

      it 'sets up the partition name' do
        model.range_partition

        expect(model.partition_name).to eq('events')
      end

      it 'extend the partition methods and range partition methods' do
        expect(model).to receive(:extend).with(Tablature::Model::PartitionMethods)
        expect(model).to receive(:extend).with(Tablature::Model::RangePartitionMethods)
        model.range_partition
      end
    end
  end

  describe Tablature::Model::ListPartitionMethods do
    describe '#create_list_partition' do
      let(:model) do
        Class.new do
          extend Tablature::Model::ListPartitionMethods
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
          extend Tablature::Model::RangePartitionMethods
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
