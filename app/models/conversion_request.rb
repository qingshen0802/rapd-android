class ConversionRequest < BaseEntity

  attr_accessor :profile_id, :from_wallet_id, :to_wallet_id, :from_currency_id, 
                :to_currency_id, :from_amount, :to_amount, :status, :user_id

end