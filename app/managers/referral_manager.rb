class ReferralManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ReferralManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Referral
  end

  def key_name
    "referral"
  end

  def plural_key_name
    "referrals"
  end  

end