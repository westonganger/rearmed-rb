module Rearmed
  def self.recursive_require(path, file_name="**/*.rb")
    require_each(path, file_name)
  end

  class << self
    alias_method :recursive_require_folder, :recursive_require
  end

  def self.require_folder(path, file_name="*.rb")
    require_each(path, file_name)
  end

  def self.naturalize_str(str)
    str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
  end

  class NaturalSortBlockFoundError < StandardError
    def initialize(klass=nil)
      super("Reaarmed doesn't yet support blocks on the natural_sort method")
    end
  end

  private

  def self.require_each(path, file_name)
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
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
      ActiveRecord::FinderMethods.module_eval do
        def all(*args)
          args.any? ? apply_finder_options(args.first) : self
        end
      end

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

Enumerable.module_eval do 
  def natural_sort_by
    sort_by{|x| Rearmed.naturalize_str(yield(x))}
  end
end

Array.module_eval do
  def find(val)
    i = index(val)
    if i
      return true if [nil, false].include?(val)
      return self[i]
    else
      return nil
    end
  end

  def natural_sort(&block)
    if block_given?
      raise Rearmed::NaturalSortBlockFoundError
    else
      block = Proc.new{|a,b| Rearmed.naturalize_str(a) <=> Rearmed.naturalize_str(b)}
    end

    sort do |a,b| 
      block.call(a,b)
    end
  end
end
