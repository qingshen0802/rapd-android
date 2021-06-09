class ConversionRequestManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ConversionRequestManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    ConversionRequest
  end

  def key_name
    "conversion_request"
  end

  def plural_key_name
    "conversion_requests"
  end

end