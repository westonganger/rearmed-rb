enumerable_enabled = Rearmed::ENABLED[:enumerable] == true

Enumerable.module_eval do 
  if enumerable_enabled || Rearmed.dig(Rearmed::ENABLED, :enumerable, :natural_sort_by) == true
    def natural_sort_by(*)
      sort_by{|x| Rearmed.naturalize_str(yield(x))}
    end
  end
    
  if enumerable_enabled || Rearmed.dig(Rearmed::ENABLED, :enumerable, :natural_sort) == true
    def natural_sort(&block)
      sort do |a,b| 
        a = Rearmed.naturalize_str(a.to_s)
        b = Rearmed.naturalize_str(b.to_s)
        if block_given?
          block.call(a,b)
        else
          a <=> b
        end
      end
    end
  end
end
