integer_enabled = Rearmed.enabled_patches[:integer] == true

Integer.class_eval do

  if integer_enabled || Rearmed.dig(Rearmed.enabled_patches, :integer, :length)
    def length
      Math.log10(self.abs).to_i + 1
    end
  end

end
