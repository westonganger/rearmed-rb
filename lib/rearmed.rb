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

  def dig(collection, *values)
    current_val = nil
    current_collection = nil
    values.each_with_index do |val,i|
      if i+1 == values.length
        current_val = current_collection[val]
      elsif val.is_a?(Array)
        if values[i+1].is_a?(Integer)
          current_collection = val
          next
        else
          current_val = nil
          break
        end
      elsif val.is_a?(Hash)
        if ['Symbol','String'].include?(values[i+1].class.name)
          current_collection = val
          next
        else
          current_val = nil
          break
        end
      else
        current_val = nil
        break 
      end
    end

    return current_val
  end

  private

  def self.require_each(path, file_name)
    file_name = File.join(File.dirname(__FILE__), path, file_name)
    Dir[file_name].each{|file| require file}
  end

  ENABLED = {
    date: {
      now: false
    },
    object: {
      not_nil: false,
      in: false
    },
    array: {
      not_empty: false,
      index_all: false, 
      delete_first: false,
      dig: false
    },
    hash: {
      only: false,
      dig: false
    },
    enumerable: {
      natural_sort: false,
      natural_sort_by: false
    },
    string: {
      valid_integer: false, 
      valid_float: false,
      to_bool: false
    },
    rails_3: {
      update_columns: false,
      pluck: false,
      all: false,
      hash_compact: false
    }
  }
end
