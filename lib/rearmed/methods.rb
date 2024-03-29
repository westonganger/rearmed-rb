module Rearmed

  def self.dig(collection, *values)
    if collection.is_a?(::Hash) || collection.is_a?(::Array)
      current_val = nil
      current_collection = collection
      values.each_with_index do |val,i|
        if i+1 == values.length
          if (current_collection.is_a?(::Array) && val.is_a?(::Integer)) || (current_collection.is_a?(::Hash) && [::String, ::Symbol].include?(val.class))
            current_val = current_collection[val]
          else
            current_val = nil
          end
        elsif current_collection.is_a?(::Array)
          if val.is_a?(::Integer)
            current_collection = current_collection[val]
            next
          else
            current_val = nil
            break
          end
        elsif current_collection.is_a?(::Hash)
          if [::String, ::Symbol].include?(val.class)
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
    else
      raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash or Array")
    end
  end

  module Hash
    def self.compact(hash)
      if hash.is_a?(::Hash)
        hash.reject{|_, value| value.nil?}
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
      end
    end

    def self.deep_set(hash, keys_array, val)
      if hash.is_a?(::Hash)
        keys_array[0...-1].inject(hash){|result, key| 
          if !result[key].is_a?(Hash)
            result[key] = {}
          end

          result[key]
        }.send(:[]=, keys_array.last, val)

        return hash
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
      end
    end

    def self.join(hash, delimiter=', ', &block)
      if hash.is_a?(::Hash)
        unless block_given?
          block = ->(k,v){ "#{k}: #{v}" }
        end

        str = ""

        hash.each_with_index do |(k,v), i| 
          val = block.call(k,v)
          unless val.is_a?(::String)
            val = val.to_s
          end
          str << val

          if i+1 < hash.length
            str << delimiter
          end
        end

        return str
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
      end
    end

    def self.only(hash, *keys)
      if hash.is_a?(::Hash)
        keys.map!{|key| hash.convert_key(key)} if hash.respond_to?(:convert_key, true)
        keys.each_with_object(hash.class.new){|k, new_hash| new_hash[k] = hash[k] if hash.has_key?(k)}
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
      end
    end

    def self.to_struct(hash)
      if hash.is_a?(::Hash)
        Struct.new(*hash.keys).new(*hash.values)
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
      end
    end
  end

  module Enumerable
    def self.natural_sort_by(collection)
      if collection.is_a?(::Enumerable) 
        collection.sort_by{|x| self._naturalize_str(yield(x))}
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be an Enumerable")
      end
    end

    def self.natural_sort(collection, options={})
      if !collection.is_a?(::Enumerable)
        raise TypeError.new("Invalid object passed to #{__method__}, must be an Enumerable")
      elsif block_given?
        Rearmed::Exceptions::BlockFoundError
      else
        collection.sort do |a,b| 
          if options[:reverse] == true
            self._naturalize_str(b.to_s) <=> self._naturalize_str(a.to_s)
          else
            self._naturalize_str(a.to_s) <=> self._naturalize_str(b.to_s)
          end
        end
      end
    end

    def self.select_map(collection)
      if collection.is_a?(::Enumerable)
        if block_given?
          collection.select{|x| yield(x) }.map{|x| yield(x) }
        else
          collection.select.map
        end
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be an Enumerable")
      end
    end

    private
    
    def self._naturalize_str(str)
      str.to_s.split(/(\d+)/).map{|a| a =~ /\d+/ ? a.to_i : a}
    end
  end

  module String
    def self.to_bool(str)
      if str.is_a?(::String)
        if str =~ /\A(true|1|t)\z/i
          true
        elsif str =~ /\A(false|0|f)\z/i
          false
        else
          nil
        end
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a String")
      end
    end

    def self.valid_integer?(str)
      if str.is_a?(::String)
        str =~ /\A\d+\z/ ? true : false
      else
        raise TypeError.new("Invalid object passed to #{__method__}")
      end
    end

    def self.valid_float?(str)
      if str.is_a?(::String)
        str =~ /(\A(\d+)(\.)?(\d+)?\z)|(\A(\d+)?(\.)(\d+)\z)/ ? true : false
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a String")
      end
    end

    def self.casecmp?(str1, str2)
      if str1.is_a?(::String)
        if str2.is_a?(::String)
          return str1.casecmp(str2) == 0
        end
      else
        raise TypeError.new("Invalid object passed to #{__method__}, must be a String")
      end
    end
  end

end
