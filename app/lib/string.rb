class String
  
  def titleize
    self.gsub('_', ' ').split.map{ |i| i.capitalize}.join(' ')
  end
  
  def camelize
    self.titleize.gsub(' ', '')
  end
  
  def constantize
    Object.const_get(self)
  end
  
  def underscore
    self.split(/(?=[A-Z])/).join(' ').gsub(' ', '_').downcase
  end

  def to_class
    Java::Lang::Class.forName("br.com.tratto.#{self}")
  end
  
  def to_java
    Java::Lang::String.new(self)
  end
  
  def html_safe
    Android::Text::Html.fromHtml(self)
  end
  
end