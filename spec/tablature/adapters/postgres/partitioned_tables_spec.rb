require 'spec_helper'

RSpec.describe Tablature::Adapters::Postgres::PartitionedTables, :database do
  it 'returns tablature partionned table object for list partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
      CREATE TABLE "events_10" PARTITION OF "events" FOR VALUES IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:list)
    expect(first.partitions).to include('events_10')
  end

  it 'returns tablature partionned table object for range partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY RANGE ("id");
      CREATE TABLE "events_10" PARTITION OF "events" FOR VALUES FROM (0) TO (10);
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:range)
    expect(first.partitions).to include('events_10')
  end

  it 'returns tablature partionned table object for hash partitions', :postgres_11 do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY HASH ("id");
      CREATE TABLE "events_0" PARTITION OF events FOR VALUES WITH (MODULUS 3, REMAINDER 0);
      CREATE TABLE "events_1" PARTITION OF events FOR VALUES WITH (MODULUS 3, REMAINDER 1);
      CREATE TABLE "events_2" PARTITION OF events FOR VALUES WITH (MODULUS 3, REMAINDER 2);
    SQL

    tables = described_class.new(connection).all
    first = tables.first

    expect(tables.size).to eq(1)
    expect(first.name).to eq('events')
    expect(first.type).to eq(:hash)
    expect(first.partitions).to match_array(['events_0', 'events_1', 'events_2'])
  end
end
