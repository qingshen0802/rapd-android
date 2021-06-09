class OnSliderRangeMovedListener
  attr_accessor :target, :action

  def initialize(target, action)
    self.target = target
    self.action = action
  end

  def onStartSliderMoved(pos)

  end

  def onEndSliderMoved(pos)
    target.send(action, pos)
  end

  def onStartSliderEvent(event)

  end

  def onEndSliderEvent(event)

  end

end