class ItemSelectedListener

  attr_accessor :target, :action

  def initialize(target, action)
    self.target = target
    self.action = action
  end

  def onItemSelected(parent, view, pos, id)
    target.send(action, pos)
  end

  def onNothingSelected(parent)

  end
end