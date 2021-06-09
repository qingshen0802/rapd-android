class NotificationManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ProfileManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Notification
  end

  def key_name
    "notification"
  end

  def plural_key_name
    "notifications"
  end  
end