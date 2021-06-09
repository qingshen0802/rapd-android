class AddressbookContactManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(AddressbookContactManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    AddressbookContact
  end

  def key_name
    "addressbook_contact"
  end

  def plural_key_name
    "addressbook_contacts"
  end  

end