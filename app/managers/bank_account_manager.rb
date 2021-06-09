class BankAccountManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(BankAccountManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    BankAccount
  end

  def key_name
    "bank_account"
  end

  def plural_key_name
    "bank_accounts"
  end

  # def fetch_all(params = {}, action = nil)
  #   options = {
  #       body: {},
  #       headers: get_user_token
  #   }
  #
  #   params_string = "&#{params.map{|k, v| "#{k}=#{v}"}.join("&")}" unless params == {}
  #
  #   Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json?page=#{current_page || 1}#{params_string}", options) do |response|
  #     if response.status >= 400
  #       self.present_error_message(response)
  #     else
  #       banks = []
  #       response.body[plural_key_name].each do |item|
  #         bank = entity_class.new(item)
  #         banks << bank
  #       end
  #       if self.delegate
  #         if action.nil?
  #           self.delegate.items_fetched(banks)
  #         else
  #           self.delegate.send(action, banks)
  #         end
  #       end
  #     end
  #   end
  # end
end