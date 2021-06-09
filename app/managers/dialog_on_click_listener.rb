class DialogOnClickListener

  attr_accessor :activity, :action, :delegate

  def initialize(activity, delegate = nil, action = nil)
    @activity = activity
    @action = action
    @delegate = delegate
  end

  def onClick(dialog, id)
    if @action != nil
      @delegate.send(@action, id)
    end
  end
end