class Wallet < BaseEntity

  attr_accessor :id, :wallet_type_id, :wallet_type, :profile_id, :user_id, :balance, :is_default

  def initialize(options = {})
    super options
    self.wallet_type = WalletType.new(options['wallet_type']) unless options['wallet_type'].nil?
  end

end