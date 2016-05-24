Enumerable.module_eval do 
  if Rearmed::ENABLED&[:enumerable]&[:natural_sort_by] || Rearmed::ENABLED&[:enumerable] == true
    def natural_sort_by
      sort_by{|x| Rearmed.naturalize_str(yield(x))}
    end

    def natural_sort_by!
      natural_sort_by(&yield).each_with_index do |item, i|
        self[i] = item
      end
    end
  end
end
