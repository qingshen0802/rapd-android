class UserRequestListener
  attr_accessor :activity

  def initialize(activity)
    @activity = activity
  end

  def onResponse(json)
    user = User.new(Moran.parse(json.toString))
    @activity.onRequestSuccess(user)
  end
end
