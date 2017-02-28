module Rearmed

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

  def self.hash_join(hash, delimiter=', ', &block)
    unless block_given?
      block = -> (k,v) {
        "#{k}: #{v}"
      }
    end

    str = ""

    hash.each_with_index do |(k,v), i| 
      val = block.call(k,v)
      unless val.is_a?(String)
        val = val.to_s
      end
      str << val

      if i+1 < hash.length
        str << delimiter
      end
    end

    return str
  end

  def self.natural_sort_by(array)
    array.sort_by{|x| self.naturalize_str(yield(x))}
  end

  def self.natural_sort(array, options={})
    if block_given?
      Rearmed::Exceptions::BlockFoundError
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
  
  def self.hash_compact(hash)
    hash.reject{|_, value| value.nil?}
  end

  def self.hash_only(hash, *keys)
    keys.map!{|key| hash.convert_key(key)} if hash.respond_to?(:convert_key, true)
    keys.each_with_object(hash.class.new){|k, new_hash| new_hash[k] = hash[k] if hash.has_key?(k)}
  end

  def self.to_bool(str)
    if str =~ /^(true|1|t|T)$/
      true
    elsif str =~ /^(false|0|f|F)$/
      false
    else
      nil
    end
  end

  def self.valid_integer?(str)
    str =~ /^\d*$/ ? true : false
  end

  def self.valid_float?(str)
    str =~ /(^(\d+)(\.)?(\d+)?$)|(^(\d+)?(\.)(\d+)$)/ ? true : false
  end

  def self.hash_to_struct(hash)
    Struct.new(*hash.keys).new(*hash.values)
  end

  private
  
  def self.naturalize_str(str)
    str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
  end

end
