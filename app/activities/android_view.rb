class Android::View::View

  attr_accessor :target, :action, :args

  def addTarget(target, action: action, *args)
    self.target = target
    self.action = action
    self.args = args
    self.OnClickListener = target
  end

  def submit
    target.send(action, *args)
  end

  def set_visible
    self.setVisibility(Android::View::View::VISIBLE)
  end

  def set_gone
    self.setVisibility(Android::View::View::GONE)
  end

  def set_invisible
    self.setVisibility(Android::View::View::INVISIBLE)
  end

  def is_visible?
    self.getVisibility == Android::View::View::VISIBLE
  end

  def text_as_string
    self.text.toString
  end

end