# Tablature

Tablature is a library built on top of ActiveRecord to simplify management of partitioned tables in Rails applications.
It ships with Postgres support and can easily supports other databases through adapters.

## Installation

##### Requirements

Tablature requires Rails 5+ and Postgres 10+.

##### Installation

Add this line to your application's Gemfile:

```ruby
gem 'tablature'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tablature

## Usage

### Partitioning a table

```ruby
class CreateEvents < ActiveRecord::Migration[5.0]
  def up
    # Create the events table as a partitioned table using range as partitioning method
    # and `event_date` as partition key.
    create_range_partition :events_by_range, partition_key: 'event_date' do |t|
      t.string :event_type, null: false
      t.integer :value, null: false
      t.date :event_date, null: false
    end

    # Create partitions with the bounds of the partition.
    create_range_partition_of :events_by_range,
      name: 'events_range_y2018m12', range_start: '2018-12-01', range_end: '2019-01-01'

    # Create the events table as a partitioned table using list as partitioning method
    # and `event_date` as partition key.
    create_list_partition :events_by_list, partition_key: 'event_date' do |t|
      t.string :event_type, null: false
      t.integer :value, null: false
      t.date :event_date, null: false
    end

    # Create partitions with the bounds of the partition.
    create_list_partition_of :events_by_list,
      name: 'events_list_y2018m12', values: (Date.parse('2018-12-01')..Date.parse('2018-12-31')).to_a

  end

  def down
    drop_table :events_by_range
    drop_table :events_by_list
  end
end
```

### Having a partition back a model

In your migration:
```ruby
# db/migrate/create_events.rb
class CreateEvents < ActiveRecord::Migration
  def change
    # You can use blocks when the partition key are SQL expression instead of
    # being only a field.
    create_range_partition :events, partition_key: -> { '(timestamp::DATE)' } do |t|
      t.string :event_type, null: false
      t.integer :value, null: false
      t.datetime :timestamp, null: false
      t.timestamps
    end

    create_range_partition_of :events,
      name: 'events_y2018m12', range_start: '2018-12-01', range_end: '2019-01-01'

    create_range_partition_of :events,
      name: 'events_y2019m01', range_start: '2019-01-01', range_end: '2019-02-01'
  end
end
```

In your model, calling one of `range_partition` or `list_partition` to inject
methods:
```
# app/models/event.rb
class Event < ApplicationRecord
  range_partition
end
```

Finally, you can now list the partitions :
```ruby
>> Event.partitions
# => ["events_y2018m12", "events_y2019m01"]
```

You can also create new partitions directly from the model :
```ruby
>> Event.create_range_partition(
    name: 'events_y2019m02',
    range_start: '2019-02-01'.to_date,
    range_end: '2019-03-01'.to_date
  )
# => ...
>> Event.partitions
# => ["events_y2018m12", "events_y2019m01", "events_y2019m02"]
```

### Partitioning an existing table
Start by renaming your table and create the partition table:
```ruby
class PartitionEvents < ActiveRecord::Migration
  def change
    # Get the bounds of the events.
    min_month = Event.minimum(:timestamp).beginning_of_month.to_date
    max_month = Event.maximum(:timestamp).beginning_of_month.to_date

    # Create the partition bounds based on the existing data. In this example,
    # we generate an array with the ranges.
    months = min_month.upto(max_month).uniq(&:beginning_of_month)

    # Rename the existing table.
    rename_table :events, :old_events

    # Create the partitioned table.
    create_range_partition :events, partition_key: -> { '(timestamp::DATE)' } do |t|
      t.string :event_type, null: false
      t.integer :value, null: false
      t.datetime :timestamp, null: false
      t.timestamps
    end

    # Create the partitions based on the bounds generated before:
    months.each do |month|
      # Creates a name like "events_y2018m12"
      partition_name = "events_y#{month.year}m#{month.month}"

      create_range_partition_of :events,
        name: partition_name, range_start: month, range_end: month.next_month
    end

    # Finally, add the rows from the old table to the new partitioned table.
    # This might take some time depending on the size of your old table.
    execute(<<~SQL)
      INSERT INTO events
      SELECT * FROM old_events
    SQL
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Acknowledgements
Tablature's structure is heavily inspired by [Scenic](https://github.com/scenic-views/scenic) and [F(x)](http://github.com/teoljungberg/fx).
Tablature's features are heavily inspired by [PgParty](https://github.com/rkrage/pg_party).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aliou/tablature.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
