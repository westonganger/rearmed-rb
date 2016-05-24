Array.module_eval do
  if Rearmed::ENABLED&[:array]&[:index_all] || Rearmed::ENABLED&[:array] == true
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

  if Rearmed::ENABLED&[:array]&[:find] || Rearmed::ENABLED&[:array] == true
    def find(item=(no_arg_passed = true;nil))
=begin
      if !no_arg_passed && block_given?
        raise Rearmed::BothArgAndBlockError
      elsif !no_arg_passed
        if !index_all().empty?
          true
        end
        index_all()[0]
      else
        raise Rearmed::NoArgOrBlockGiven
      end
=end
    end
  end

  if Rearmed::ENABLED&[:array]&[:natural_sort] || Rearmed::ENABLED&[:array] == true
    def natural_sort(&block)
      if block_given?
        raise Rearmed::NaturalSortBlockFoundError
      end

      sort{|a,b| Rearmed.naturalize_str(a.to_s) <=> Rearmed.naturalize_str(b.to_s)}
    end

    def natural_sort!
      natural_sort(&yield).each_with_index do |item, i|
        self[i] = item
      end
    end
  end

  if Rearmed::ENABLED&[:array]&[:delete_first] || Rearmed::ENABLED&[:array] == true
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
end
