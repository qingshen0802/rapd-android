class UserManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(UserManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    User
  end

  def key_name
    "user"
  end

  def plural_key_name
    "users"
  end  
  
  def confirm_sms(sms_code)
    url = "#{app_delegate.base_url}/api/users/#{current_user.remote_id}/confirm_via_sms.json?sms_confirmation_code=#{sms_code}"
    options = {
      body: {},
      headers: get_user_token
    }
    
    Net.get(url, options) do |response|
      self.delegate.confirmed_sms(response)
    end
  end
  
  def reset_password(phone_number)
    url = "#{app_delegate.base_url}/api/users/reset_password_sms_confirmation.json?phone_number=#{phone_number}"
    
    options = {
      body: {},
      headers: get_api_token
    }
    
    Net.get(url, options) do |response|
      self.delegate.redefined_password(response)
    end
  end
  
  def reset_password_confirm(sms_code, user_id)
    url = "#{app_delegate.base_url}/api/users/password_reset_confirm_via_sms.json?id=#{user_id}&sms_confirmation_code=#{sms_code}"
    options = {
      body: {},
      headers: get_api_token
    }
    
    Net.get(url, options) do |response|
      self.delegate.reseted_password(response)
    end
  end
  
  def resend_sms(user_id, user_token)
    url = "#{app_delegate.base_url}/api/users/#{user_id}/trigger_sms_confirmation.json"
    options = {
      body: {},
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{user_token}"
      }
    }
    
    Net.get(url, options) do |response|
      self.delegate.resent_sms(response)
    end
  end

end