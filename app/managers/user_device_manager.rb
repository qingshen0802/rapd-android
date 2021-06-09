class UserDeviceManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(UserDeviceManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    UserDevice
  end

  def key_name
    "user_device"
  end

  def plural_key_name
    "user_devices"
  end  

end