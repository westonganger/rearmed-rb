module Rearmed
  def self.recursive_require(path, file_name="**/*.rb")
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
  end

  def self.require_folder(path, file_name="*.rb")
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
  end

  def self.naturalize_str(str)
    #TODO: BENCHMARK
    #str.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
    str.scan(/[^\d\.]+|[\d\.]+/).collect{|f| f.match(/\d+(\.\d+)?/) ? f.to_f : f}
  end
end

if defined?(Rails)
  # Rails 3
  if Rails.version =~ /^3\./
    Hash.class_eval do
      def compact
        self.select{|_, value| !value.nil?}
      end

      def compact!
        self.reject!{|_, value| value.nil?}
      end
    end

    if defined?(ActiveRecord)
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
  end
end

Array.module_eval do 
  def natural_sort_by(&block)
    sort_by{|x| Rearmed.naturalize_str(eval(block.source))}
  end
end
