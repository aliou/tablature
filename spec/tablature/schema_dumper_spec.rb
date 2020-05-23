require 'spec_helper'

class Event < ActiveRecord::Base; end

RSpec.describe Tablature::SchemaDumper, :database do
  it 'ignores the partitions' do
    Event.connection.create_range_partition :events, partition_key: :id
    Event.connection.create_range_partition_of :events, name: :events_10,
                                                        range_start: 0,
                                                        range_end: 10
    stream = StringIO.new

    ActiveRecord::SchemaDumper.dump(Event.connection, stream)

    output = stream.string
    expect(output).to_not include('events_10')
  end

  it 'dumps create_range_partition for a range partition in the database' do
    Event.connection.create_range_partition :events, partition_key: :id
    stream = StringIO.new

    ActiveRecord::SchemaDumper.dump(Event.connection, stream)

    output = stream.string
    expect(output).to include('create_range_partition "events"')
  end
end
