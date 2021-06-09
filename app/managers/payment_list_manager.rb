class PaymentListManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(PaymentListManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    PaymentList
  end

  def key_name
    "payment_list"
  end

  def plural_key_name
    "payment_lists"
  end  

end