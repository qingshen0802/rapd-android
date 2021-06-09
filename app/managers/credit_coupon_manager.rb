class CreditCouponManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(CreditCouponManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    CreditCoupon
  end

  def key_name
    "credit_coupon"
  end

  def plural_key_name
    "credit_coupons"
  end

  def get_token
    {
        'Content-Type' => 'application/json',
        'Authorization' => "#{app_delegate.access_token}"
    }
  end

  def register_coupon(id, profile_id)
    options = {
        body: {},
        headers: get_token
    }

    Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{id}/register?profile_id=#{profile_id}", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.delegate.resource_creation_failed if self.delegate
        self.present_error_message(response)
      else
        self.delegate.resource_created(entity_class.new(response.body[key_name])) if self.delegate
      end
    end
  end

end