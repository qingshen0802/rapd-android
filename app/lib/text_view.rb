class TextView < Android::Widget::TextView
  
  def setFocusable(focusable)
    self.setTypeface(Utils.get_typeface_from_asset(getContext, "Roboto-Bold"))
    
    super(focusable)
  end
  
end