if Rearmed::ENABLED&[:rails_3]&[:hash]&[:compact] || Rearmed::ENABLED&[:string] == true
  String.module_eval do
    def valid_float?
      Rearmed.valid_float(self)
    end
  end
end
