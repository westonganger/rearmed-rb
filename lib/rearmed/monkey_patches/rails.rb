enabled = Rearmed.enabled_patches[:rails] == true

if defined?(ActiveRecord)

  ActiveRecord::Base.class_eval do
    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :reset_table)
      def self.reset_table
        case self.connection.adapter_name.downcase.to_sym
        when :mysql2
          self.delete_all
          self.connection.execute("ALTER TABLE #{self.table_name} AUTO_INCREMENT = 1")
        when :postgresql
          self.connection.execute("TRUNCATE TABLE #{self.table_name} RESTART IDENTITY")
        when :sqlite3
          self.connection.execute("DELETE FROM #{self.table_name}")
          self.connection.execute("DELETE FROM sqlite_sequence WHERE NAME='#{self.table_name}'")
        end
        self.reset
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :reset_auto_increment)
      def self.reset_auto_increment(opts={})
        value = (opts[:value] || 1)

        case self.connection.adapter_name.downcase.to_sym
        when :mysql2
          self.connection.execute("ALTER TABLE #{self.table_name} AUTO_INCREMENT = #{value}")
        when :postgresql
          self.connection.execute("ALTER SEQUENCE #{self.table_name}_#{(opts[:column] || :id).to_s}_seq RESTART WITH #{value}")
        when :sqlite3
          self.connection.execute("UPDATE SQLITE_SEQUENCE SET SEQ=#{value-1} WHERE NAME='#{self.table_name}'")
        end
        self.reset
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :dedupe)
      def self.dedupe(opts={})
        if !opts[:columns]
          opts[:columns] = self.column_names.except!(:id)
        end
        
        if opts[:skip_timestamps]
          opts[:columns].except!(:created_at, :updated_at, :deleted_at)
        end

        self.all.group_by{|model| opts[:columns].map{|x| model[x]}}.values.each do |duplicates|
          (opts[:keep] && opts[:keep] == :last) ? duplicates.pop : uplicates.shift
          duplicates.each{|x| x.destroy}
        end
        self.reset
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :find_or_create)
      def self.find_or_create(attrs={}, save_opts={})
        unless self.where(attrs).limit(1).first
          x = self.class.new(attrs)
          x.save(save_opts)
          return t
        end
      end

      def self.find_or_create!(attrs={}, save_opts={})
        unless self.where(attrs).limit(1).first
          x = self.class.new(attrs)
          x.save!(save_opts)
          return t
        end
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :pluck_to_hash)
      def self.pluck_to_hash(*keys)
        hash_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:hash_type, HashWithIndifferentAccess) : HashWithIndifferentAccess
        block_given = block_given?
        keys, formatted_keys = format_keys(keys)
        keys_one = keys.size == 1

        pluck(*keys).map do |row|
          value = hash_type[formatted_keys.zip(keys_one ? [row] : row)]
          block_given ? yield(value) : value
        end
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :pluck_to_struct)
      def self.pluck_to_struct(*keys)
        struct_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:struct_type, Struct) : Struct
        block_given = block_given?
        keys, formatted_keys = format_keys(keys)
        keys_one = keys.size == 1

        struct = struct_type.new(*formatted_keys)
        pluck(*keys).map do |row|
          value = keys_one ? struct.new(*[row]) : struct.new(*row)
          block_given ? yield(value) : value
        end
      end
    end

    private

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :pluck_to_hash) || Rearmed.dig(Rearmed.enabled_patches, :rails, :pluck_to_struct)
      def self.format_keys(keys)
        if keys.blank?
          [column_names, column_names]
        else
          [
            keys,
            keys.map do |k|
              case k
              when String
                k.split(/\bas\b/i)[-1].strip.to_sym
              when Symbol
                k
              end
            end
          ]
        end
      end
    end
  end

  ActiveRecord::Batches.module_eval do
    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :find_in_relation_batches)
      def find_in_relation_batches(options = {})
        options.assert_valid_keys(:start, :batch_size)

        relation = self
        start = options[:start]
        batch_size = options[:batch_size] || 1000

        unless block_given?
          return to_enum(:find_in_relation_batches, options) do
            total = start ? where(table[primary_key].gteq(start)).size : size
            (total - 1).div(batch_size) + 1
          end
        end

        if logger && (arel.orders.present? || arel.taken.present?)
          logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        relation = relation.reorder(batch_order).limit(batch_size)
        #records = start ? relation.where(table[primary_key].gteq(start)).to_a : relation.to_a
        records = start ? relation.where(table[primary_key].gteq(start)) : relation

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id
          raise "Primary key not included in the custom select clause" unless primary_key_offset

          yield records

          break if records_size < batch_size

          records = relation.where(table[primary_key].gt(primary_key_offset))#.to_a
        end
      end
    end

    if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :find_relation_each)
      def find_relation_each(options = {})
        if block_given?
          find_in_relation_batches(options) do |records|
            records.each { |record| yield record }
          end
        else
          enum_for :find_relation_each, options do
            options[:start] ? where(table[primary_key].gteq(options[:start])).size : size
          end
        end
      end
    end
  end

end
