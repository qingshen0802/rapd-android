class ReportManager < BaseManager
  @@manager = ""
  attr_accessor :manager, :type

  def self.shared_manager
    unless @@manager.is_a?(ReportManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def key_name
     type == "monthly" || type.nil? ?  "monthly_report" :  "yearly_report"
  end

   def entity_class
    key_name.camelize.constantize
  end

  def plural_key_name
    type == "monthly" ?  "monthly_reports" :  "yearly_reports"
  end  

end