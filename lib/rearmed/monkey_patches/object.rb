object_enabled = Rearmed.enabled_patches[:object] == true

Object.class_eval do
  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :not_nil) == true
    def not_nil?
      !nil?
    end
  end

  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :in) == true
    def in?(array, *more)
      if !more.empty?
        array = [array, *more]
      end
      array.include?(self)
    end
  end
end
