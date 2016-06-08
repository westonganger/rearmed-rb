date_enabled = Rearmed.enabled_patches[:date] == true

Date.class_eval do
  if date_enabled || Rearmed.dig(Rearmed.enabled_patches, :date, :now) == true
    def self.now
      DateTime.now.to_date
    end
  end
end
