module Rearmed
  def self.naturalize_str(str)
    str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
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

  ENABLED = {
    rails_4: {
      or: false,
      link_to_confirm: false,
      find_relation_each: false,
      find_in_relation_batches: false
    },
    rails_3: {
      hash_compact: false,
      pluck: false,
      update_columns: false,
      all: false
    },
    string: {
      to_bool: false,
      valid_integer: false,
      valid_float: false
    },
    hash: {
      only: false,
      dig: false
    },
    array: {
      index_all: false,
      find: false,
      dig: false,
      delete_first: false
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
    }
  }
end
