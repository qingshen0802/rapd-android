class ConversationManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ConversationManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Conversation
  end

  def key_name
    "conversation"
  end

  def plural_key_name
    "conversations"
  end  

end