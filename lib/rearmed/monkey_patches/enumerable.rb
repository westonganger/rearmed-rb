enumerable_enabled = Rearmed.enabled_patches == :all || Rearmed.enabled_patches[:enumerable] == true

Enumerable.module_eval do 
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort_by)
    def natural_sort_by
      Rearmed::Enumerable.natural_sort_by(self){|x| yield(x)}
    end
  end
    
  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :natural_sort)
    def natural_sort(options={})
      if block_given?
        Rearmed::Enumerable.natural_sort(self, options){|x| yield(x)}
      else
        Rearmed::Enumerable.natural_sort(self, options)
      end
    end
  end

  if enumerable_enabled || Rearmed.dig(Rearmed.enabled_patches, :enumerable, :select_map)
    def select_map
      if block_given?
        Rearmed::Enumerable.select_map(self){|x| yield(x)}
      else
        Rearmed::Enumerable.select_map(self)
      end
    end
  end
end
