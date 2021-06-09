class Java::Lang::String
  
  def html_safe
    Android::Text::Html.fromHtml(self)
  end  
  
end