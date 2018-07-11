object_enabled = Rearmed.enabled_patches == :all || Rearmed.enabled_patches[:object] == true

Object.class_eval do
  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :not_nil)
    def not_nil?
      !self.nil?
    end
  end

  if !Object.new.respond_to?(:in?) && (object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :in))
    def in?(array, *more)
      if !more.empty?
        array = [array, *more]
      end
      array.include?(self)
    end
  end

  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :bool?)
    def bool?
      self.is_a?(TrueClass) || self.is_a?(FalseClass)
    end
  end

  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :false?)
    def false?
      self.is_a?(FalseClass)
    end
  end

  if object_enabled || Rearmed.dig(Rearmed.enabled_patches, :object, :true?)
    def true?
      self.is_a?(TrueClass)
    end
  end
end
