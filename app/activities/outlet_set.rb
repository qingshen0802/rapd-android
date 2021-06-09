class OutletSet
  
  attr_accessor :package_name, :parent, :view
  
  def initialize(options = {})
    options.map do |k, v| 
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end
  end
  
  def [](key)
    self.view.findViewById(parent.resources.getIdentifier(key, 'id', package_name))
  end
  
end