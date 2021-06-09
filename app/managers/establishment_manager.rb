class EstablishmentManager < BaseManager

  @@manager = ""
  attr_accessor :manager
  
  def self.shared_manager
    unless @@manager.is_a?(EstablishmentManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Profile
  end

  def key_name
    "company"
  end

  def plural_key_name
    "companies"
  end  

end