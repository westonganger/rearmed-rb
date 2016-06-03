date_enabled = Rearmed::ENABLED[:date] == true

Date.class_eval do
  if date_enabled || Rearmed.dig(Rearmed::ENABLED, :date, :now) == true
    def self.now
      DateTime.now.to_date
    end
  end
end
