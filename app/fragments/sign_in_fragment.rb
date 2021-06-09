class SignInFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end    

  def get_title
    get_string('sign_in')
  end
  
  def load_views
    self.outlets['forgot_password'].addTarget(self, action: 'forgot_password')
    self.outlets['login_button'].addTarget(self, action: 'login')
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    true
  end
  
  def forgot_password
    switch_to_fragment('forgot_password', container: 'welcome')
  end
  
  def login
    @dialog = Utils.loading_dialog(getActivity())
    
    email = self.outlets['name_or_cpf'].text.toString
    password = self.outlets['password'].text.toString
    
    login_manager = LoginManager.shared_manager
    login_manager.delegate = self
    login_manager.login(email, password)
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
  
  def onClick(button)
    super(button)
  end
  
  def logged_in
    load_default_profile
  end
  
  def login_failed
    @dialog.dismiss
  end
  
  def has_back_arrow?
    true
  end

  def has_drawer_toggle?
    false
  end
end
