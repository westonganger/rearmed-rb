hash_enabled = Rearmed::ENABLED&[:hash] == true

Hash.class_eval do
  if hash_enabled || Rearmed.dig(Rearmed::ENABLED, :hash, :only) == true
    def only(*keys)
      keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
      keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end

    def only!(*keys)
      keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
      omit = slice(*self.keys - keys)
      hash = slice(*keys)
      hash.default      = default
      hash.default_proc = default_proc if default_proc
      replace(hash)
      omit
    end
  end
end
