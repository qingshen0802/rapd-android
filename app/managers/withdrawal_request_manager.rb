class WithdrawalRequestManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(WithdrawalRequestManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    WithdrawalRequest
  end

  def key_name
    "withdrawal_request"
  end

  def plural_key_name
    "withdrawal_requests"
  end  

end