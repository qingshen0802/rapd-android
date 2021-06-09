class AddressManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(AddressManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Address
  end

  def key_name
    "address"
  end

  def plural_key_name
    "addresses"
  end  

end