string_enabled = Rearmed.enabled_patches[:string] == true

String.class_eval do
  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :valid_integer)
    def valid_integer?
      Rearmed.valid_integer?(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :valid_float)
    def valid_float?
      Rearmed.valid_float?(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :to_bool)
    def to_bool
      Rearmed.to_bool(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :starts_with)
    alias_method :starts_with?, :start_with?
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :begins_with)
    alias_method :begins_with?, :start_with?
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :ends_with)
    alias_method :ends_with?, :end_with?
  end
end
