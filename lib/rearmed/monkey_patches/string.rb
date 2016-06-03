string_enabled = Rearmed::ENABLED[:string] == true

String.class_eval do
  if string_enabled || Rearmed.dig(Rearmed::ENABLED, :string, :valid_integer) == true
    def valid_integer?
      self =~ /^\d*$/
    end
  end

  if string_enabled || Rearmed.dig(Rearmed::ENABLED, :string, :valid_float) == true
    def valid_float?
      str =~ /(^(\d+)(\.)?(\d+)?)|(^(\d+)?(\.)(\d+))/
    end
  end

  if string_enabled || Rearmed.dig(Rearmed::ENABLED, :string, :to_bool) == true
    def to_bool
      if self =~ /^true$/
        true
      elsif self =~ /^false$/
        false
      else
        raise(ArgumentError.new "incorrect element #{self}")
      end
    end
  end
end

