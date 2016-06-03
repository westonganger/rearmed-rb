array_enabled = Rearmed::ENABLED[:array] == true

Array.module_eval do
  if array_enabled || Rearmed.dig(Rearmed::ENABLED, :array, :not_empty) == true
    def not_empty?
      !empty?
    end
  end

  if array_enabled || Rearmed.dig(Rearmed::ENABLED, :array, :index_all) == true
    def index_all(item=(no_arg_passed = true;nil))
      if !no_arg_passed && block_given?
        raise Rearmed::BothArgAndBlockError
      elsif !no_arg_passed
        each_index.select{|i| arr[i] == item}
      elsif block_given?
        each_index.select{|i| yield(i)}
      else
        raise Rearmed::NoArgOrBlockGiven
      end
    end
  end

  if array_enabled || Rearmed.dig(Rearmed::ENABLED, :array, :delete_first) == true
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

  if RUBY_VERSION.to_f < 2.3 && array_enabled || Rearmed.dig(Rearmed::ENABLED, :array, :dig) == true
    def dig(*args)
      Rearmed.dig(self, *args)
    end
  end
end
