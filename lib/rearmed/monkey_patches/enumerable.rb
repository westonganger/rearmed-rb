enumerable_enabled = Rearmed.enabled_patches == :all || Rearmed.enabled_patches[:enumerable] == true

Enumerable.module_eval do 
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort_by)
    def natural_sort_by
      Rearmed.natural_sort_by(self){|x| yield(x)}
    end
  end
    
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort)
    def natural_sort(options={})
      if block_given?
        Rearmed.natural_sort(self, options){|x| yield(x)}
      else
        Rearmed.natural_sort(self, options)
      end
    end
  end

  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :select_map)
    def select_map
      if block_given?
        Rearmed.select_map(self){|x| yield(x)}
      else
        Rearmed.select_map(self)
      end
    end
  end
end
