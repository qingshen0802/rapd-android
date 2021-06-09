class MonthFormatter

    def initialize () 
    end

    def getFormattedValue(value, entry)
      values = ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"]
      values[value.to_i].to_java    
    end

    def getDecimalDigits() 
      0 
    end
end