string_enabled = Rearmed.enabled_patches[:string] == true

String.class_eval do
  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :valid_integer) == true
    def valid_integer?
      Rearmed.valid_integer?(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :valid_float) == true
    def valid_float?
      Rearmed.valid_float?(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :to_bool) == true
    def to_bool
      Rearmed.to_bool(self)
    end
  end
end

