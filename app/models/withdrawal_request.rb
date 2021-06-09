class WithdrawalRequest < BaseEntity

  attr_accessor :amount, :profile_id, :currency_id, :bank_account_id, :human_amount, :status, :request_description, :request_type, :prepaid_card_delivery_address, :prepaid_card_id, :wallet_id, :user_id

end