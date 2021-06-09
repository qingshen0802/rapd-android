class CreditCardManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(CreditCardManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    CreditCard
  end

  def key_name
    "credit_card"
  end

  def plural_key_name
    "credit_cards"
  end  

end