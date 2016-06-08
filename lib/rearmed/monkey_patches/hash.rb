hash_enabled = Rearmed.enabled_patches[:hash] == true

Hash.class_eval do
  if hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :only) == true
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

  if RUBY_VERSION.to_f < 2.3 && hash_enabled || Rearmed.dig(Rearmed.enabled_patches, :hash, :dig) == true
    def dig(*args)
      Rearmed.dig(self, *args)
    end
  end
end
