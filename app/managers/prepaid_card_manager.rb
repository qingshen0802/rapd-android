class PrepaidCardManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(PrepaidCardManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    PrepaidCard
  end

  def key_name
    "prepaid_card"
  end

  def plural_key_name
    "prepaid_cards"
  end  

end