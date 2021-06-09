class LoginManager < BaseManager

  @@manager = ""
  attr_accessor :delegate
  
  def app_delegate
    if defined?(UIApplication)
      UIApplication.sharedApplication.delegate
    else
      AppDelegate.shared_delegate
    end
  end

  def login_facebook(facebook_id, provider)
     url = "#{app_delegate.base_url}/api/users.json"

     options = {
      body: {
        facebook_id: facebook_id,
        provider: provider
      },
      
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{app_delegate.api_access_token}"
      }
    }
    
    Net.post(url, options) do |response|
      if response.status >= 400
        delegate.login_failed 
      else
        app_delegate.set_user(response.body["user"].merge(remote_id: response.body["user"]["id"]))
        app_delegate.set_profile_ids(response.body["user"]["profile_ids"])
        delegate.logged_in
      end
    end
  end 

  def sign_up
    switch_to_fragment('sign_up', container: 'welcome')
  end  

  def self.shared_manager
    @@manager.is_a?(LoginManager) ? @@manager : new
  end

  def login(email, password)
    url = "#{app_delegate.base_url}/api/tokens.json"
    
    options = {
      body: {
        email: email,
        password: password
      },
      
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{app_delegate.api_access_token}"
      }
    }
    puts "#{url}, #{options}"
    Net.post(url, options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.present_error_message(response)
        delegate.login_failed
      else
        app_delegate.set_user(response.body["user"].merge(remote_id: response.body["user"]["id"]))
        app_delegate.set_profile_ids(response.body["user"]["profile_ids"])
        delegate.logged_in
      end
    end
  end

  def logout
    app_delegate.empty_for_logout    
  end

end