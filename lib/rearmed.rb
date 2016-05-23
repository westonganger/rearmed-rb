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

  class BlockFoundError < StandardError
    def initialize(klass=nil)
      super("Rearmed doesn't yet support a block on this method.")
    end
  end

  class NoArgOrBlockGivenError < StandardError
    def initialize(klass=nil)
      super("Must pass an argument or a block.")
    end
  end

  class BothArgAndBlockError < StandardError
    def initialize(klass=nil)
      super("Arguments and blocks must be used seperately.")
    end
  end

  private

  def self.require_each(path, file_name)
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
  end
end


Object.class_eval do
  def not_nil?
    !nil?
  end

  def in?(obj)
    obj.include(self)
  end
end


Numeric.class_eval do 
  def to_positive
    if self < 0
      -self
    else
      self
    end
  end
end


String.class_eval do
  def valid_integer?
    self =~ /^\d*$/
  end

  def valid_float?
    self =~ /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/
  end

  def to_bool
    if self =~ /^true$/
      true
    elsif self =~ /^false$/
      false
    else
      raise(ArgumentError.new "incorrect element #{self}")
    end
  end
end

Date.class_eval do
  def self.now
    DateTime.now.to_date
  end
end


Enumerable.module_eval do 
  def natural_sort_by
    sort_by{|x| Rearmed.naturalize_str(yield(x))}
  end

  def natural_sort_by!
    natural_sort_by(&yield).each_with_index do |item, i|
      self[i] = item
    end
  end
end


Array.class_eval do
  def not_empty?
    !empty?
  end

  def index_all(item)
    if block_given?
      raise Rearmed::BlockFoundError
    else
      each_index.select{|i| arr[i] == item}
    end
  end

  def natural_sort
    if block_given?
      raise Rearmed::BlockFoundError
    else
      block = Proc.new{|a,b| Rearmed.naturalize_str(a) <=> Rearmed.naturalize_str(b)}
    end

    sort do |a,b| 
      block.call(a,b)
    end
  end

  def natural_sort!
    natural_sort(&yield).each_with_index do |item, i|
      self[i] = item
    end
  end

  def delete_first(item = (no_arg_passed = true; nil))
    if block_given? && !no_arg_passed
      raise Rearmed::BothArgAndBlockError
    elsif block_given?
      self.delete_at(index{|x| yield(x)})
    elsif item || !no_arg_passed
      self.delete_at(index(item) || length)
    else
      self.delete_at(0)
    end
  end
end


if defined?(Rails)
  Hash.class_eval do
    alias_method :only, :slice
    alias_method :only!, :slice!
  end


  if Rails.version < 4.1
    Hash.class_eval do
      def compact
        self.select{|_, value| !value.nil?}
      end

      def compact!
        self.reject!{|_, value| value.nil?}
      end
    end
  end


  if Rails.version[0] == '3'
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
            if attributes.length > 1
              attributes.map do |key, attr|
                klass.type_cast_attribute(key, initialized_attributes)
              end
            else
              klass.type_cast_attribute(attributes.keys.first, initialized_attributes)
            end
          end
        end
      end

    end
  end
end
