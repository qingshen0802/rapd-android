class ValueFormatter
    attr_accessor :mFormat, :currency_prefix
   
    def initialize(currency_prefix)
        mFormat =  Java::Text::DecimalFormat.new("###,###,##0.00")
        self.currency_prefix = currency_prefix
    end

    def getFormattedValue(value, entry, dataSetIndex, viewPortHandler) 
        "#{self.currency_prefix} #{value.to_f.round(2).toString.gsub(/[.]/, ',').gsub(/(\d)(?=(\d{3})+\,\b)/,'\1.')}".to_java
    end

    def getDecimalDigits
      0
    end
end
