class DocumentManager < BaseManager

  @@manager = ""
  attr_accessor :manager

  def self.shared_manager
    unless @@manager.is_a?(DocumentManager)
      @@manager = new
      @@manager.prefix = "/"
    end
    @@manager
  end

  def entity_class
    Document
  end

  def key_name
    "document"
  end

  def plural_key_name
    "documents"
  end
  
  def create_resource(document)
    if document.any_attachment?
      attachment = document.attachment
      document.attachment = nil
      
      options = {
        body: {
          "#{key_name}" => document.to_json
        },
        
        headers: get_user_token,
        attachment: {
          name: "document[attachment]",
          file: attachment
        }
      }
      
      Net.post("#{app_delegate.base_url}#{api_prefix}#{prefix}#{plural_key_name}.json", options) do |response|
        puts "#{response.body}"
        if response.status >= 400
          self.delegate.resource_creation_failed if self.delegate
          self.present_error_message(response)
        else
          self.delegate.resource_created(entity_class.new(response.body[key_name])) if self.delegate
        end
      end
    else
      super(document)
    end
  end

end