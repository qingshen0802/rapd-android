class CurrencyManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(CurrencyManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Currency
  end

  def key_name
    "currency"
  end

  def plural_key_name
    "currencies"
  end

  def convert(params)
    options = {
      body: {},
      headers: get_api_token
    }

    params_string = "&#{params.map{|k, v| "#{k}=#{v}"}.join("&")}" unless params == {}

    Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/convert.json?#{params_string}", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.present_error_message(response)
      else
        delegate.currency_converted response.body
      end
    end
  end

end