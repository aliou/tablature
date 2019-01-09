require 'tablature/model/partition_methods'

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
      def list_partition(partition_name = table_name)
        setup_partition(partition_name)
        extend(PartitionMethods)
        extend(ListPartitionMethods)
      end

      def range_partition(partition_name = table_name)
        setup_partition(partition_name)
        extend(PartitionMethods)
        extend(RangePartitionMethods)
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
