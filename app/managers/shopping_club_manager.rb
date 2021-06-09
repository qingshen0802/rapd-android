class ShoppingClubManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ShoppingClubManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    ShoppingClub
  end

  def key_name
    "shopping_club"
  end

  def plural_key_name
    "shopping_clubs"
  end  

end