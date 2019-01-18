module Tablature
  module Model
    module ListPartitionMethods
      def create_list_partition(options)
        Tablature.database.create_list_partition_of(tablature_partition.name, options)
      end
    end

    module RangePartitionMethods
      def create_range_partition(options)
        Tablature.database.create_range_partition_of(tablature_partition.name, options)
      end
    end

    module ClassMethods
      extend Forwardable

      def_delegators :tablature_partition, :partitions, :partition_key, :partitioning_method

      def partitioned?
        begin
          tablature_partition
        rescue Tablature::MissingPartition
          return false
        end

        true
      end

      def tablature_partition
        partition = Tablature.database.partitioned_tables.find do |pt|
          pt.name == partition_name.to_s
        end
        raise Tablature::MissingPartition if partition.nil?

        partition
      end

      def list_partition(partition_name = table_name)
        setup_partition(partition_name)
        extend(ListPartitionMethods)
      end

      def range_partition(partition_name = table_name)
        setup_partition(partition_name)
        extend(RangePartitionMethods)
      end

      # @api private
      def inspect
        return super unless partitioned?

        # Copied from the Rails source.
        attr_list = attribute_types.map { |name, type| "#{name}: #{type.type}" } * ', '
        "#{self}(#{attr_list})"
      end

      private

      def setup_partition(partition_name)
        class_attribute(:partition_name)
        self.partition_name = partition_name
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end
