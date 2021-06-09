class Transaction < BaseEntity

  attr_accessor :amount_in_cents, :attachment, :bank_installment_code, :credit_card_id, :currency_short_name, 
                :expires_at, :human_amount, :profile, :profile_id, :should_charge, :status, :stripe_data, 
                :stripe_token, :transaction_type, :transactionable_id, :transactionable_type, 
                :user_id, :wallet, :wallet_id, :amount

  def initialize(options = {})
    super options
    self.wallet = Wallet.new(options['wallet']) unless options['wallet'].nil?
  end

  def any_attachment?
    attachment
  end

  def approved?
    self.status == 'approved'
  end

end