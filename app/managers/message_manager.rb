class MessageManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(MessageManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Message
  end

  def key_name
    "message"
  end

  def plural_key_name
    "messages"
  end  

end