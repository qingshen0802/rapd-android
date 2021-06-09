class ErrorListener
  attr_accessor :activity

  def initialize(activity)
    @activity = activity
  end

  def onErrorResponse(error)
    @activity.onRequestError(error)
  end
end
