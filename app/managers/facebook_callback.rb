class FacebookCallback
  
  attr_accessor :activity, :user, :fragment

  def initialize(fragment)
    self.fragment = fragment
    @activity = fragment.getActivity
  end
  
  def onSuccess(login_result)
    @token = login_result.getAccessToken().getToken()
    @activity.facebook_logged_in(@token)
    request = Com::Facebook::GraphRequest.newMeRequest(login_result.getAccessToken(), self)
    parameters = Android::Os::Bundle.new
    parameters.putString(
      "fields", "id, first_name, last_name, email, gender, picture")
    request.setParameters(parameters)
    request.executeAsync 
  end

  def onCompleted(object, response)   
    facebookUser = User.new
    facebookUser.email = object.getString("email")
    facebookUser.facebook_id = object.getString("id")
    facebookUser.facebook_token = @token
    facebookUser.name = object.getString("first_name") + " " + object.getString("last_name")
    self.fragment.return_user(facebookUser)
  end            

  def onCancel
    p "====== ON CANCEL ====="
  end

  def onError(exception)
    p "====== ON ERROR ====="
  end
end
