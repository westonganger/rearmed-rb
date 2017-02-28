enabled = Rearmed.enabled_patches[:rails] == true

if defined?(ActiveRecord)
  ar_enabled = enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record) == true

  ActiveRecord::Base.class_eval do
    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :newest)
      def self.newest(*columns)
        if columns.empty? || !columns.to_s.include?('created_at')
          columns << 'created_at'
        end

        the_order = {}
        columns.each do |x|
          the_order[x.to_s] = :desc
        end
        self.order(the_order).limit(1).first
      end
    end

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :reset_table)
      def self.reset_table(opts={})
        if opts[:delete_method] && opts[:delete_method].to_sym == :destroy
          if self.try(:paranoid?)
            self.unscoped.each do |x|
              if x.respond_to?(:really_destroy!)
                x.really_destroy!
              else
                x.destroy!
              end
            end
          else
            self.unscoped.destroy_all
          end
        end

        case self.connection.adapter_name.downcase.to_sym
        when :mysql2
          if !opts[:delete_method] || opts[:delete_method].to_sym != :destroy
            if defined?(ActsAsParanoid) && self.try(:paranoid?)
              self.unscoped.delete_all!
            else
              self.unscoped.delete_all
            end
          end
          self.connection.execute("ALTER TABLE #{self.table_name} AUTO_INCREMENT = 1")
        when :postgresql
          self.connection.execute("TRUNCATE TABLE #{self.table_name} RESTART IDENTITY")
        when :sqlite3
          self.connection.execute("DELETE FROM #{self.table_name}")
          self.connection.execute("DELETE FROM sqlite_sequence WHERE NAME='#{self.table_name}'")
        end
      end
    end

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :reset_auto_increment)
      def self.reset_auto_increment(opts={})
        case self.connection.adapter_name.downcase.to_sym
        when :mysql2
          opts[:value] = 1 if opts[:value].blank?
          self.connection.execute("ALTER TABLE #{self.table_name} AUTO_INCREMENT = #{opts[:value]}")
        when :postgresql
          opts[:value] = 1 if opts[:value].blank?
          self.connection.execute("ALTER SEQUENCE #{self.table_name}_#{opts[:column].to_s || self.primary_key}_seq RESTART WITH #{opts[:value]}")
        when :sqlite3
          opts[:value] = 0 if opts[:value].blank?
          self.connection.execute("UPDATE SQLITE_SEQUENCE SET SEQ=#{opts[:value]} WHERE NAME='#{self.table_name}'")
        end
      end
    end

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :find_duplicates)
      def self.find_duplicates(*args)
        options = {}

        unless args.empty?
          if args.last.is_a?(Hash)
            options = args.pop
          end

          unless args.empty?
            if args.count == 1 && args.first.is_a?(Array)
              args = args.first
            end

            options[:columns] = args
          end
        end
        
        options[:columns] ||= self.column_names.reject{|x| [self.primary_key, :created_at, :updated_at, :deleted_at].include?(x)}

        duplicates = self.select("#{options[:columns].join(', ')}, COUNT(*)").group(options[:columns]).having("COUNT(*) > 1")

        if options[:delete]
          if options[:delete] == true
            options[:delete] = {keep: :first, delete_method: :destroy, soft_delete: true}
          else
            options[:delete][:delete_method] ||= :destroy
            options[:delete][:keep] ||= :first
            if options[:delete][:soft_delete] != false
              options[:delete][:soft_delete] = true
            end
          end

          if options[:delete][:keep] == :last
            duplicates.reverse!
          end

          used  = []
          duplicates.reject! do |x| 
            attrs = x.attributes.slice(*options[:columns].collect(&:to_s))

            if used.include?(attrs)
              return false
            else
              used.push attrs
              return true
            end
          end
          used = nil

          if options[:delete][:delete_method].to_sym == :delete
            duplicates = self.where(id: duplicates.collect(&:id))

            if x.respond_to?(:delete_all!)
              duplicates.delete_all!
            else
              duplicates.delete_all
            end
          else
            duplicates.each do |x|
              if !options[:delete][:soft_delete] && x.respond_to?(:really_destroy!)
                x.really_destroy!
              else
                x.destroy!
              end
            end
          end
          return nil
        else
          return duplicates
        end
      end
    end

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :find_or_create)
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

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :pluck_to_hash)
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

    if enabled || ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :pluck_to_struct)
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

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :pluck_to_hash) || Rearmed.dig(Rearmed.enabled_patches, :rails, :pluck_to_struct)
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
    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :find_in_relation_batches)
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
          raise ActiveRecordError, "Primary key not included in the custom select clause" unless primary_key_offset

          yield records

          break if records_size < batch_size

          records = relation.where(table[primary_key].gt(primary_key_offset))#.to_a
        end
      end
    end

    if ar_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :active_record, :active_record, :find_relation_each)
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

if defined?(ActionView::Helpers)
  other_enabled = enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :other) == true

  ActionView::Helpers.module_eval do

    if other_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :other, :options_for_select_include_blank)
      def options_for_select(container, selected = nil)
        return container if String === container

        if selected.is_a?(Hash)
          include_blank = selected[:include_blank] || selected['include_blank']
        end

        selected, disabled = extract_selected_and_disabled(selected).map do |r|
          Array(r).map(&:to_s)
        end

        options = []

        options.push([nil,nil]) if include_blank

        container.each do |element|
          html_attributes = option_html_attributes(element)
          text, value = option_text_and_value(element).map(&:to_s)

          html_attributes[:selected] ||= option_value_selected?(value, selected)
          html_attributes[:disabled] ||= disabled && option_value_selected?(value, disabled)
          html_attributes[:value] = value

          options.push content_tag_string(:option, text, html_attributes)
        end

        options.join("\n").html_safe
      end
    end

    if other_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :other, :options_from_collection_for_select_include_blank)
      def options_from_collection_for_select(collection, value_method, text_method, selected = nil)
        options = collection.map do |element|
          [value_for_collection(element, text_method), value_for_collection(element, value_method), option_html_attributes(element)]
        end

        if selected.is_a?(Hash)
          include_blank = selected[:include_blank] || selected['include_blank']
        end

        selected, disabled = extract_selected_and_disabled(selected)

        select_deselect = {
          selected: extract_values_from_collection(collection, value_method, selected),
          disabled: extract_values_from_collection(collection, value_method, disabled),
          include_blank: include_blank
        }

        options_for_select(options, select_deselect)
      end
    end

    if other_enabled || Rearmed.dig(Rearmed.enabled_patches, :rails, :other, :field_is_array)
      original_method = instance_method(:add_default_name_and_id)
      define_method :add_default_name_and_id do |options|
        if options['is_array'] && options['name']
          options['name'] = "#{options['name']}[]"
        end
        original_method.bind(self).(options)
      end
    end

  end
end
