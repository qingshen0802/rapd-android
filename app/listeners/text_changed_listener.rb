class TextChangedListener

  attr_accessor :target, :action

  def initialize(target, action)
    self.target = target
    self.action = action
  end

  def afterTextChanged(s)
    target.send(action)
  end

  def onTextChanged(s, start, before, count)
  end

  def beforeTextChanged(s, start, count, after)
  end

end