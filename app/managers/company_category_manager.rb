class CompanyCategoryManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(CompanyCategoryManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    CompanyCategory
  end

  def key_name
    "company_category"
  end

  def plural_key_name
    "company_categories"
  end  

end