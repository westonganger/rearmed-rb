object_enabled = Rearmed::ENABLED&[:object] == true

Object.class_eval do

  if object_enabled || Rearmed.dig(Rearmed::ENABLED, :object, :not_nil) == true
    def not_nil?
      !nil?
    end
  end

  if object_enabled || Rearmed.dig(Rearmed::ENABLED, :object, :in) == true
    def in?(obj)
      obj.include(self)
    end
  end
end
