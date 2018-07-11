string_enabled = Rearmed.enabled_patches[:string] == true

String.class_eval do
  if !''.respond_to?(:casecmp?) && (string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :casecmp?))
    def casecmp?(str)
      Rearmed.casecmp?(self, str)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :to_bool)
    def to_bool
      Rearmed.to_bool(self)
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :match?)
    def match?(pattern, pos=0)
      match(pattern, pos).not_nil?
    end
  end

  if string_enabled || Rearmed.dig(Rearmed.enabled_patches, :string, :valid_number)
    def valid_number?
      Rearmed.valid_number?(self)
    end
  end

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
