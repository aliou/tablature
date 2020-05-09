require 'spec_helper'

RSpec.describe Tablature::CommandRecorder do
  let(:recorder) { ActiveRecord::Migration::CommandRecorder.new }

  describe '#create_list_partition' do
    it 'records the created list partitioned table' do
      recorder.create_list_partition :events, { partition_key: :id }

      expect(recorder.commands).to eq [
        [:create_list_partition, [:events, { partition_key: :id }], nil]
      ]
    end

    it 'reverts to drop_table' do
      recorder.revert do
        recorder.create_list_partition :events, { partition_key: :id }
      end

      expect(recorder.commands).to eq [[:drop_table, [:events]]]
    end
  end

  describe '#create_list_partition_of' do
    it 'records the created list partition' do
      recorder.create_list_partition_of :events, name: 'events_default', default: true

      expect(recorder.commands).to eq [
        [:create_list_partition_of, [:events, { name: 'events_default', default: true }], nil]
      ]
    end

    it 'reverts to drop_table' do
      recorder.revert do
        recorder.create_list_partition_of :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [[:drop_table, ['events_default']]]
    end
  end

  describe '#attach_to_list_partition' do
    it 'records the attached list partition' do
      recorder.attach_to_list_partition :events, name: 'events_default', default: true

      expect(recorder.commands).to eq [
        [:attach_to_list_partition, [:events, { name: 'events_default', default: true }], nil]
      ]
    end

    it 'reverts to detach the list partition' do
      recorder.revert do
        recorder.attach_to_list_partition :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [
        [:detach_from_list_partition, [:events, { name: 'events_default', default: true }]]
      ]
    end
  end

  describe '#detach_from_list_partition' do
    it 'records the detached list partition' do
      recorder.detach_from_list_partition :events, name: 'events_default'

      expect(recorder.commands).to eq [
        [:detach_from_list_partition, [:events, { name: 'events_default' }], nil]
      ]
    end

    it "raises when the partition bound spec isn't given" do
      expect do
        recorder.revert do
          recorder.detach_from_list_partition :events, name: 'events_default'
        end
      end.to raise_error(ActiveRecord::IrreversibleMigration)
    end

    it 'reverts to attach the list partition when the partition bound spec is given' do
      recorder.revert do
        recorder.detach_from_list_partition :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [
        [:attach_to_list_partition, [:events, { name: 'events_default', default: true }]]
      ]
    end
  end

  describe '#create_range_partition' do
    it 'records the created range partitioned table' do
      recorder.create_range_partition :events, { partition_key: :id }

      expect(recorder.commands).to eq [
        [:create_range_partition, [:events, { partition_key: :id }], nil]
      ]
    end

    it 'reverts to drop_table' do
      recorder.revert do
        recorder.create_range_partition :events, { partition_key: :id }
      end

      expect(recorder.commands).to eq [[:drop_table, [:events]]]
    end
  end

  describe '#create_range_partition_of' do
    it 'records the created range partition' do
      recorder.create_range_partition_of :events, name: 'events_default', default: true

      expect(recorder.commands).to eq [
        [:create_range_partition_of, [:events, { name: 'events_default', default: true }], nil]
      ]
    end

    it 'reverts to drop_table' do
      recorder.revert do
        recorder.create_range_partition_of :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [[:drop_table, ['events_default']]]
    end
  end

  describe '#attach_to_range_partition' do
    it 'records the attached range partition' do
      recorder.attach_to_range_partition :events, name: 'events_default', default: true

      expect(recorder.commands).to eq [
        [:attach_to_range_partition, [:events, { name: 'events_default', default: true }], nil]
      ]
    end

    it 'reverts to detach the range partition' do
      recorder.revert do
        recorder.attach_to_range_partition :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [
        [:detach_from_range_partition, [:events, { name: 'events_default', default: true }]]
      ]
    end
  end

  describe '#detach_from_range_partition' do
    it 'records the detached range partition' do
      recorder.detach_from_range_partition :events, name: 'events_default'

      expect(recorder.commands).to eq [
        [:detach_from_range_partition, [:events, { name: 'events_default' }], nil]
      ]
    end

    it "raises when the partition bound spec isn't given" do
      expect do
        recorder.revert do
          recorder.detach_from_range_partition :events, name: 'events_default'
        end
      end.to raise_error(ActiveRecord::IrreversibleMigration)
    end

    it 'reverts to attach the range partition when the partition bound spec is given' do
      recorder.revert do
        recorder.detach_from_range_partition :events, name: 'events_default', default: true
      end

      expect(recorder.commands).to eq [
        [:attach_to_range_partition, [:events, { name: 'events_default', default: true }]]
      ]
    end
  end
end
