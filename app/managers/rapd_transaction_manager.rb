class RapdTransactionManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(RapdTransactionManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    RapdTransaction
  end

  def key_name
    "rapd_transaction"
  end

  def plural_key_name
    "rapd_transactions"
  end

  def create_resource(resource)
    options = {
      body: {
        "#{key_name}" => resource.to_json
      },
      
      headers: resource.is_a?(User) ? get_api_token : get_user_token
    }
    
    Net.post("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.delegate.resource_creation_failed if self.delegate
        self.present_error_message(response)
      else
        if self.delegate
          self.delegate.resource_created
        end
      end
    end
  end

end