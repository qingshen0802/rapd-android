module BaseActivity
    
  def present_activity(activity_name)
    activity = "#{activity_name}_activity".camelize.to_class
    intent = Android::Content::Intent.new(self, activity)
    startActivity(intent)
    finish
  end
  
  def method_missing(method, *args, &block)
    if method.to_s =~ /^present/
      present_activity(method.to_s.gsub("present_", ""))
    end
  end
  
end