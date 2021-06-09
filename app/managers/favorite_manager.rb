class FavoriteManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(FavoriteManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Favorite
  end

  def key_name
    "favorite"
  end

  def plural_key_name
    "favorites"
  end  

end