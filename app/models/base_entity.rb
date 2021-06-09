class BaseEntity

  attr_accessor :remote_id, :created_at, :updated_at

  def initialize(options = {})
    self.remote_id = options["id"] if options['id']
    options.map{|k, v| self.send("#{k}=", v) if self.respond_to?("#{k}=")}
  end

  def new_record?
    remote_id.nil?
  end
  
  def attributes
    instance_variables.collect{|i| i.to_s.gsub(/^@/, '')}
  end
  
  def to_json
    json = {}
    
    attributes.each do |attribute|
      json["#{attribute}"] = instance_variable_get("@#{attribute}")
    end
    
    json
  end

end