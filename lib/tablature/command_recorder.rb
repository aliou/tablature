module Tablature
  # @api private
  module CommandRecorder
    def create_list_partition(*args)
      record(:create_list_partition, args)
    end

    def create_list_partition_of(*args)
      record(:create_list_partition_of, args)
    end

    def attach_to_list_partition(*args)
      record(:attach_to_list_partition, args)
    end

    def detach_from_list_partition(*args)
      record(:detach_from_list_partition, args)
    end

    def create_range_partition(*args)
      record(:create_range_partition, args)
    end

    def create_range_partition_of(*args)
      record(:create_range_partition_of, args)
    end

    def attach_to_range_partition(*args)
      record(:attach_to_range_partition, args)
    end

    def detach_from_range_partition(*args)
      record(:detach_from_range_partition, args)
    end

    def invert_create_partition(args)
      [:drop_table, [args.first]]
    end

    alias :invert_create_list_partition :invert_create_partition
    alias :invert_create_range_partition :invert_create_partition

    def invert_create_partition_of(args)
      _parent_table_name, options = args
      partition_name = options[:name]

      [:drop_table, [partition_name]]
    end

    alias :invert_create_list_partition_of :invert_create_partition_of
    alias :invert_create_range_partition_of :invert_create_partition_of

    def invert_attach_to_range_partition(args)
      [:detach_from_range_partition, args]
    end

    def invert_detach_from_range_partition(args)
      parent_table_name, options = args
      options ||= {}
      _partition_name = options[:name]

      range_start = options[:range_start]
      range_end = options[:range_end]
      default = options[:default]

      if (range_start.nil? || range_end.nil?) && default.blank?
        message = <<-MESSAGE
          invert_detach_from_range_partition is reversible only if given bounds or the default option
        MESSAGE
        raise ActiveRecord::IrreversibleMigration, message
      end

      [:attach_to_range_partition, [parent_table_name, options]]
    end

    def invert_attach_to_list_partition(args)
      [:detach_from_list_partition, args]
    end

    def invert_detach_from_list_partition(args)
      partitioned_table, options = args
      options ||= {}

      default = options[:default]
      values = options[:values] || []

      if values.blank? && default.blank?
        message = <<-MESSAGE
          invert_detach_from_list_partition is reversible only if given the value list or the default option
        MESSAGE
        raise ActiveRecord::IrreversibleMigration, message
      end

      [:attach_to_list_partition, [partitioned_table, options]]
    end
  end
end
