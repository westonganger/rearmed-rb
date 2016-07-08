enabled = Rearmed.enabled_patches[:rails_3] == true

if defined?(ActiveRecord) && ActiveRecord::VERSION::MAJOR < 4

  if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_3, :all)
    ActiveRecord::FinderMethods.module_eval do
      def all(*args)
        args.any? ? apply_finder_options(args.first) : self
      end
    end
  end

  if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_3, :update_columns)
    ActiveRecord::Persistence::ClassMethods.module_eval do
      def update_columns(attributes)
        raise ActiveRecordError, "cannot update a new record" if new_record?
        raise ActiveRecordError, "cannot update a destroyed record" if destroyed?

        attributes.each_key do |key|
          raise ActiveRecordError, "#{key.to_s} is marked as readonly" if self.class.readonly_attributes.include?(key.to_s)
        end

        updated_count = self.class.unscoped.where(self.class.primary_key => id).update_all(attributes)

        attributes.each do |k, v|
          raw_write_attribute(k, v)
        end

        updated_count == 1
      end
    end
  end

  if enabled || Rearmed.dig(Rearmed.enabled_patches, :rails_3, :pluck)
    ActiveRecord::Relation.class_eval do
      def pluck(*args)
        args.map! do |column_name|
          if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
            "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
          else
            column_name.to_s
          end
        end

        relation = clone
        relation.select_values = args
        klass.connection.select_all(relation.arel).map! do |attributes|
          initialized_attributes = klass.initialize_attributes(attributes)
          attributes.map do |key, attr|
            klass.type_cast_attribute(key, initialized_attributes)
          end
        end
      end
    end
  end

end
