array_enabled = Rearmed.enabled_patches[:array] == true

Array.module_eval do
  if array_enabled || Rearmed.dig(Rearmed.enabled_patches, :array, :not_empty) == true
    def not_empty?
      !empty?
    end
  end

  if array_enabled || Rearmed.dig(Rearmed.enabled_patches, :array, :delete_first) == true
    def delete_first(item = (no_arg_passed = true; nil))
      if block_given? && !no_arg_passed
        raise BothArgAndBlockError
      elsif block_given?
        self.delete_at(self.index{|x| yield(x)} || self.length)
      elsif item || !no_arg_passed
        self.delete_at(self.index(item) || self.length)
      else
        self.delete_at(0)
      end
    end
  end

  if RUBY_VERSION.to_f < 2.3 && array_enabled || Rearmed.dig(Rearmed.enabled_patches, :array, :dig) == true
    def dig(*args)
      Rearmed.dig(self, *args)
    end
  end
end
