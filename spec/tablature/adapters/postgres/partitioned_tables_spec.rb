require 'spec_helper'

RSpec.describe Tablature::Adapters::Postgres::PartitionedTables, :database do
  it 'returns tablature partitioned table object for list partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY LIST ("id");
      CREATE TABLE "events_10" PARTITION OF "events" FOR VALUES IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    SQL

    tables = described_class.new(connection).all
    partitioned_table = tables.first

    expect(tables.size).to eq(1)
    expect(partitioned_table.name).to eq('events')
    expect(partitioned_table.partition_key).to eq('(id)')
    expect(partitioned_table.partitioning_method).to eq(:list)
    expect(partitioned_table.partitions).to include('events_10')
  end

  it 'returns tablature partionned table object for range partitions' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL) PARTITION BY RANGE ("id");
      CREATE TABLE "events_10" PARTITION OF "events" FOR VALUES FROM (0) TO (10);
    SQL

    tables = described_class.new(connection).all
    partitioned_table = tables.first

    expect(tables.size).to eq(1)
    expect(partitioned_table.name).to eq('events')
    expect(partitioned_table.partition_key).to eq('(id)')
    expect(partitioned_table.partitioning_method).to eq(:range)
    expect(partitioned_table.partitions).to include('events_10')
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
    partitioned_table = tables.first

    expect(tables.size).to eq(1)
    expect(partitioned_table.name).to eq('events')
    expect(partitioned_table.partition_key).to eq('(id)')
    expect(partitioned_table.partitioning_method).to eq(:hash)
    expect(partitioned_table.partitions).to match_array(['events_0', 'events_1', 'events_2'])
  end

  it 'correctly handles partitions with expressions as partition key' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL, ts timestamp NOT NULL) PARTITION BY RANGE ((ts::date));
      CREATE TABLE "events_2019" PARTITION OF "events" FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');
    SQL

    tables = described_class.new(connection).all
    partitioned_table = tables.first

    expect(partitioned_table.partition_key).to eq('(((ts)::date))')
  end

  it 'correctly handles partitions with multiple columns as partition key' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL, date date NOT NULL) PARTITION BY RANGE (id, date);
      CREATE TABLE "events_2019" PARTITION OF "events" FOR VALUES FROM (1, '2019-01-01') TO (100, '2020-01-01');
    SQL

    tables = described_class.new(connection).all
    partitioned_table = tables.first

    expect(partitioned_table.partition_key).to eq('(id, date)')
  end

  it 'correctly handles partitions with columns and expressions as partition key' do
    connection = ActiveRecord::Base.connection
    connection.execute <<-SQL
      CREATE TABLE "events" ("id" bigserial NOT NULL, ts timestamp NOT NULL) PARTITION BY RANGE (id, (ts::date));
      CREATE TABLE "events_2019" PARTITION OF "events" FOR VALUES FROM (1, '2019-01-01') TO (100, '2020-01-01');
    SQL

    tables = described_class.new(connection).all
    partitioned_table = tables.first

    expect(partitioned_table.partition_key).to eq('(id, ((ts)::date))')
  end
end
