enumerable_enabled = Rearmed.enabled_patches[:enumerable] == true

Enumerable.module_eval do 
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort_by) == true
    def natural_sort_by
      Rearmed.natural_sort_by(self){|x| yield(x)}
    end
  end
    
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort) == true
    def natural_sort(options={})
      if block_given?
        Rearmed.natural_sort(self, options){|x| yield(x)}
      else
        Rearmed.natural_sort(self, options)
      end
    end
  end
end
