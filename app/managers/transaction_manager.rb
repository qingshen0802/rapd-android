class TransactionManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(TransactionManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Transaction
  end

  def key_name
    "transaction"
  end

  def plural_key_name
    "transactions"
  end

  def update_resource(transaction)
    if transaction.any_attachment?
      attachment = transaction.attachment
      transaction.attachment = nil
      
      options = {
        body: {
          "#{key_name}" => transaction.to_json
        },
        
        headers: get_user_token,
        attachment: {
          name: "transaction[attachment]",
          file: attachment
        }
      }

      Net.patch("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{transaction.remote_id}.json", options) do |response|
        puts "#{response.body}"
        if response.status >= 400
          self.delegate.resource_update_failed if self.delegate
          self.present_error_message(response)
        else
          self.delegate.resource_updated(entity_class.new(response.body[key_name])) if self.delegate
        end
      end
    else
      super transaction
    end
  end

end