require 'spec_helper'

RSpec.describe Tablature::Statements do
  describe '.create_list_partition' do
    it 'raises an error if the partition key is not defined' do
      expect do
        connection.create_list_partition(:events, partition_key: nil)
      end.to raise_error ArgumentError
    end
  end

  describe '.create_range_partition' do
    it 'raises an error if the partition key is not defined' do
      expect do
        connection.create_range_partition(:events, partition_key: nil)
      end.to raise_error ArgumentError
    end
  end

  def connection
    Class.new { extend Tablature::Statements }
  end
end
