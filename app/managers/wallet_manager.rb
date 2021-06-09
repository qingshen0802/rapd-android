class WalletManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(WalletManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Wallet
  end

  def key_name
    "wallet"
  end

  def plural_key_name
    "wallets"
  end

  def fetch_all(params = {}, action = nil)
    options = {
      body: {},
      headers: get_user_token
    }
    
    params_string = "&#{params.map{|k, v| "#{k}=#{v}"}.join("&")}" unless params == {}
    
    Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json?page=#{current_page || 1}#{params_string}", options) do |response|
      puts "#{response.body{plural_key_name}}"
      if response.status >= 400
        self.present_error_message(response)
      else
        wallets = []
        response.body[plural_key_name].each do |item|
          wallet = entity_class.new(item)

          if wallet.is_default
            app_delegate.set_default_wallet item
          end

          wallets << wallet
        end
        if self.delegate
          if action.nil?
            self.delegate.items_fetched(wallets)  
          else
            self.delegate.send(action, wallets)
          end
        end
      end
    end
  end

end