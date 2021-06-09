class FocusChangeListener 
  attr_accessor :target, :action
  
  def initialize(target, action)
    self.target = target
    self.action = action
  end

  def onFocusChange(view, hasFocus)
    target.send(action, view, hasFocus)
  end

end