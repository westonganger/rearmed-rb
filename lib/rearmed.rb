module Rearmed

  @enabled_patches = {
    rails_4: {
      or: false,
      link_to_confirm: false
    },
    rails_3: {
      pluck: false,
      update_columns: false,
      all: false
    },
    rails: {
      pluck_to_hash: false,
      pluck_to_struct: false,
      find_or_create: false,
      find_duplicates: false,
      reset_table: false,
      reset_auto_increment: false,
      find_relation_each: false,
      find_in_relation_batches: false,
    },
    string: {
      valid_integer: false,
      valid_float: false,
      to_bool: false,
      starts_with: false,
      begins_with: false,
      ends_with: false
    },
    hash: {
      only: false,
      dig: false,
      compact: false
    },
    array: {
      dig: false,
      delete_first: false,
      not_empty: false
    },
    enumerable: {
      natural_sort: false,
      natural_sort_by: false
    },
    object: {
      in: false,
      not_nil: false
    },
    date: {
      now: false
    },
    minitest: {
      assert_changed: false,
      assert_not_changed: false
    }
  }

  def self.enabled_patches=(val)
    @enabled_patches = val
  end

  def self.enabled_patches
    @enabled_patches
  end

  def self.valid_integer?(str)
    str =~ /^\d*$/ ? true : false
  end

  def self.valid_float?(str)
    str =~ /(^(\d+)(\.)?(\d+)?$)|(^(\d+)?(\.)(\d+)$)/ ? true : false
  end

  def self.to_bool(str)
    if str =~ /^true$/
      true
    elsif str =~ /^false$/
      false
    else
      #raise(ArgumentError.new "incorrect element #{str}")
      nil
    end
  end

  def self.natural_sort_by(array)
    array.sort_by{|x| self.naturalize_str(yield(x))}
  end

  def self.natural_sort(array, options={})
    if block_given?
      BlockFoundError
    else
      array.sort do |a,b| 
        if options[:reverse] == true
          self.naturalize_str(b.to_s) <=> self.naturalize_str(a.to_s)
        else
          self.naturalize_str(a.to_s) <=> self.naturalize_str(b.to_s)
        end
      end
    end
  end

  def self.only(hash, *keys)
    keys.map!{|key| hash.convert_key(key)} if hash.respond_to?(:convert_key, true)
    keys.each_with_object(hash.class.new){|k, new_hash| new_hash[k] = hash[k] if hash.has_key?(k)}
  end

  def self.dig(collection, *values)
    current_val = nil
    current_collection = collection
    values.each_with_index do |val,i|
      if i+1 == values.length
        if (current_collection.is_a?(Array) && val.is_a?(Integer)) || (current_collection.is_a?(Hash) && ['String','Symbol'].include?(val.class.name))
          current_val = current_collection[val]
        else
          current_val = nil
        end
      elsif current_collection.is_a?(Array)
        if val.is_a?(Integer)
          current_collection = current_collection[val]
          next
        else
          current_val = nil
          break
        end
      elsif current_collection.is_a?(Hash)
        if ['Symbol','String'].include?(val.class.name)
          current_collection = current_collection[val]
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
  
  def self.naturalize_str(str)
    str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
  end

end
