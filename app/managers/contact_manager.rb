class ContactManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ContactManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Contact
  end

  def key_name
    "contact"
  end

  def plural_key_name
    "contacts"
  end  

end