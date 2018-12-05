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
    drop_table :events
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
