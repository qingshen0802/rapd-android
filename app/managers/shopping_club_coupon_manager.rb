class ShoppingClubCouponManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ShoppingClubCouponManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    ShoppingClubCoupon
  end

  def key_name
    "shopping_club_coupon"
  end

  def plural_key_name
    "shopping_club_coupons"
  end  

end