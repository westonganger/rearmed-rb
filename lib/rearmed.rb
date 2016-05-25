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
    # DONT ALIAS ACTIVE SUPPORT

    alias_method :only, :slice
    alias_method :only!, :slice!
  end
end
