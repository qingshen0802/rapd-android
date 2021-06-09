class AxisFormatter

  attr_accessor :currency_prefix

    def initialize(currency_prefix) 
      self.currency_prefix = currency_prefix
    end

    def getFormattedValue( value, axis) 
      "#{self.currency_prefix} #{value.round(0)}".to_java
    end

    def getDecimalDigits() 
      0
    end
end