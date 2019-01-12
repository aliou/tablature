require 'forwardable'

module Tablature
  module Model
    module PartitionMethods
      extend Forwardable
      def_delegators :tablature_partition, :partitions, :partition_key, :partitioning_method

      def tablature_partition
        partition = Tablature.database.partitioned_tables.find do |pt|
          pt.name == partition_name.to_s
        end
        raise Tablature::MissingPartition if partition.nil?

        partition
      end

      def partitioned?
        begin
          tablature_partition
        rescue Tablature::MissingPartition
          return false
        end

        true
      end
    end
  end
end
