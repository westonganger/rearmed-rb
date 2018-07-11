if Rearmed.enabled_patches == :all || Rearmed.enabled_patches[:date] == true || Rearmed.dig(Rearmed.enabled_patches, :date, :now)

  require 'date'

  Date.class_eval do

    def self.now
      DateTime.now.to_date
    end

  end

end
