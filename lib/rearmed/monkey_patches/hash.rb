hash_enabled = Rearmed.enabled_patches[:hash] == true

Hash.class_eval do
  allowed = defined?(ActiveSupport) ? (ActiveSupport::VERSION::MAJOR > 3) : true
  if allowed && (hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :compact))
    def compact
      self.select{|_, value| !value.nil?}
    end

    def compact!
      self.reject!{|_, value| value.nil?}
    end
  end

  if RUBY_VERSION.to_f < 2.3 && hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :dig)
    def dig(*args)
      Rearmed.dig(self, *args)
    end
  end

  if hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :join)
    def join(delimiter=', ', &block)
      if block_given?
        Rearmed.join(self, delimiter, &block)
      else
        Rearmed.join(self, delimiter)
      end
    end
  end

  if hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :only)
    def only(*keys)
      Rearmed.only(self, *keys)
    end

    def only!(*keys)
      keys.map!{ |key| convert_key(key) } if respond_to?(:convert_key, true)
      omit = only(*self.keys - keys)
      hash = only(*keys)
      replace(hash)
      omit
    end
  end

  if hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :to_struct)
    def to_struct
      Struct.new(*keys).new(*values)
    end
  end
end
