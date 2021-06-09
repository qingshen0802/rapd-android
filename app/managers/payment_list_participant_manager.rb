class PaymentListParticipantManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(PaymentListParticipantManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    PaymentListParticipant
  end

  def key_name
    "payment_list_participant"
  end

  def plural_key_name
    "payment_list_participants"
  end  

end