class WelcomeFragment < Android::Support::V4::App::Fragment
  
  include BaseView
  include FragmentManager
  
  attr_accessor :outlets, :user, :profile, :fragment

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def onCreate(savedInstanceState)
    super
    Com::Facebook::FacebookSdk.sdkInitialize(getActivity())
    @callback_manager = Com::Facebook::CallbackManager::Factory.create()
  end

  def has_actionbar?
    false
  end  

  def load_views
    self.outlets['sign_in_button'].addTarget(self, action: "sign_in")
    self.outlets['sign_in_button'].text = get_string('sign_in_button').html_safe
    self.outlets['sign_up_button'].addTarget(self, action: "sign_up")
    self.outlets['sign_in_facebook_button'].addTarget(self,action:"facebook_login")
    self.outlets['facebook_login_button'].setReadPermissions(["email".to_java])
    self.outlets['facebook_login_button'].setFragment(self)
    self.outlets['facebook_login_button'].registerCallback(@callback_manager, FacebookCallback.new(self))

  end

  def sign_up
    switch_to_fragment('sign_up', container: 'welcome')
  end

  def facebook_login
    self.outlets['facebook_login_button'].performClick()
  end

  def main_fragment
    switch_to_fragment('main', container: 'welcome')
  end
  
  def sign_in
    switch_to_fragment('sign_in', container: 'welcome')
  end
  
  def onClick(button)
    if button == self.outlets['facebook_login_button']
      if (app_delegate.logged_in?)
      main_fragment
      else   
      button.performClick()
      end 
    else
      super(button)
    end
  end
 
  def onActivityResult(requestCode, resultCode, data)
    super
    @callback_manager.onActivityResult(requestCode, resultCode, data)
  end  

  def return_user(user)
    @user = user
    facebook_logged_in(@user.facebook_id)
  end

  def logged_in
    load_default_profile
  end
  
  def login_failed
    app_delegate.set_user(@user)
    sign_up
  end  

  def load_default_profile
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.fetch_all
  end
  
  def items_fetched(profiles)
    profiles.each{|profile| app_delegate.send("set_#{profile.type.downcase}_profile",profile)}
    getActivity.present_main
  end
  
  def facebook_logged_in(facebook_id)

    login_manager = LoginManager.shared_manager
    login_manager.delegate = self
    login_manager.login_facebook(facebook_id, "facebook")
  end
end
