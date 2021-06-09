class TransactionRequest < BaseEntity

  attr_accessor :from_profile_id, :to_profile_id, :amount, :request_description,
                :rapd_transaction_id, :user_id, :currency_id,
                :human_amount, :status, :to_profile
end