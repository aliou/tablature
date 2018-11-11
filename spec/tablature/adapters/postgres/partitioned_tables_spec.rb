require 'spec_helper'

RSpec.describe Tablature::Adapters::Postgres::PartitionedTables, :database do
  it 'returns tablature partionned table object for list partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id")
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:list)
  end

  it 'returns tablature partionned table object for range partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY RANGE ("id")
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:range)
  end

  it 'returns tablature partionned table object for hash partitions', :postgres_11 do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY HASH ("id")
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:hash)
  end
end
