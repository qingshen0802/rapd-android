class BaseManager
  
  attr_accessor :delegate, :prefix, :current_page
  
  def app_delegate
    if defined?(UIApplication)
      UIApplication.sharedApplication.delegate
    else
      AppDelegate.shared_delegate
    end
  end
  
  def api_prefix
    "/api"
  end
  
  def entity_class
    raise "Should be implemented in child class"
  end
  
  def key_name
    raise "Should be implemented in child class"
  end
  
  def plural_key_name
    raise "Should be implemented in child class"
  end
  
  def get_api_token
    {
      'Content-Type' => 'application/json',
      'Authorization' => "#{app_delegate.api_access_token}"
    }
  end
  
  def get_user_token
    {
      'Content-Type' => 'application/json',
      'Authorization' => "#{app_delegate.access_token}"
    }
  end
  
  def current_user
    app_delegate.current_user
  end
  
  def fetch_all(params = {}, action = nil, uses_api_auth = false)
    options = {
      body: {},
      headers: uses_api_auth ? get_api_token : get_user_token
    }
    
    params_string = "&#{params.map{|k, v| "#{k}=#{v}"}.join("&")}" unless params == {}

    Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json?page=#{current_page || 1}#{params_string}", options) do |response|
      puts "#{response.body[plural_key_name]}"
      if response.status >= 400
        self.present_error_message(response)
      else
        items = []
        response.body[plural_key_name].each do |item|
          items << entity_class.new(item)
        end
        if self.delegate
          if action.nil?
            self.delegate.items_fetched(items)  
          else
            self.delegate.send(action, items)
          end
        end
      end
    end
  end
  
  def fetch(id, params = {})
    options = {
      body: {},
      headers: get_user_token
    }
    
    params_string = "#{params.map{|k, v| "#{k}=#{v}"}.join("&")}" unless params == {}
    
    Net.get("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{id}.json?#{params_string}", options) do |response|
      puts "#{response.body{plural_key_name}}"
      if response.status >= 400
        self.present_error_message(response)
      else
        self.delegate.item_fetched(entity_class.new(response.body[key_name])) if self.delegate
      end
    end
  end
  
  def create_resource(resource)
    options = {
      body: {
        "#{key_name}" => resource.to_json
      },
      
      headers: resource.is_a?(User) ? get_api_token : get_user_token
    }
    # puts "#{get_user_token}"
    puts "#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}, #{options}"
    Net.post("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.delegate.resource_creation_failed if self.delegate
        self.present_error_message(response)
      else
        self.delegate.resource_created(entity_class.new(response.body[key_name])) if self.delegate
      end
    end
  end

  def update_resource(resource)
    options = {
      body: {
        "#{key_name}" => resource.to_json
      },
      
      headers: get_user_token
    }
    
    Net.patch("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{resource.remote_id}.json", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.delegate.resource_update_failed if self.delegate
        self.present_error_message(response)
      else
        self.delegate.resource_updated(entity_class.new(response.body[key_name])) if self.delegate
      end
    end
  end
  
  def present_error_message(response)
    activity = self.delegate.is_a?(Android::Support::V4::App::Fragment) ? self.delegate.getActivity : self.delegate
    Utils.show_dialog(activity, "Erro", response.body["message"])
  end
  
  def delete_resource(resource)
    options = {
      body: {},
      headers: get_user_token
    }
    
    Net.delete("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{resource.remote_id}.json", options) do |response|
      puts "#{response.body}"
      if response.status >= 400
        self.delegate.resource_delete_failed if self.delegate
        self.present_error_message(response)
      else
        self.delegate.resource_deleted if self.delegate
      end
    end
  end

end
