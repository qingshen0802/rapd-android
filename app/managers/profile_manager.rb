class ProfileManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(ProfileManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Profile
  end

  def key_name
    "profile"
  end

  def plural_key_name
    "profiles"
  end  
  
  def create_resource(profile)
    if profile.any_attachment?
      photo = profile.photo
      profile.photo = nil
      
      options = {
        body: {
          "#{key_name}" => profile.to_json
        },
        
        headers: profile.is_a?(User) ? get_api_token : get_user_token,
        attachment: {
          name: "profile[photo]",
          file: photo
        }
      }
      
      Net.post("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json", options) do |response|
        if response.status >= 400
          self.delegate.resource_creation_failed if self.delegate
          self.present_error_message(response)
        else
          self.delegate.resource_created(entity_class.new(response.body[key_name])) if self.delegate
        end
      end
    else
      super(profile)
    end
  end
  
  def update_resource(resource)
    if resource.any_attachment?
      attachment = resource.photo
      resource.photo = nil

      options = {
          body: {
              "#{key_name}" => resource.to_json
          },

          headers: get_user_token,
          attachment: {
              name: "profile[photo]",
              file: attachment
          }
      }
      puts "#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}, #{options}"
      Net.patch("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}/#{resource.remote_id}.json", options) do |response|
        puts "#{response.body}"
        if response.status >= 400
          self.delegate.resource_update_failed if self.delegate
          self.present_error_message(response)
        else
          self.delegate.resource_updated(entity_class.new(response.body['profile'])) if self.delegate
        end
      end
    else
      super resource
    end
  end

end