class WalletTypeManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(WalletTypeManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    WalletType
  end

  def key_name
    "wallet_type"
  end

  def plural_key_name
    "wallet_types"
  end

end