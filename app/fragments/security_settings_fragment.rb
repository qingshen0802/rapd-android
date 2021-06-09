class SecuritySettingsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('security_settings_title')
  end
    
  def load_views
    outlets['toggle_alert'].setChecked app_delegate.current_profile.touch_id_active
    outlets['toggle_alert'].onCheckedChangeListener = self
  end
  
  def onCheckedChanged(buttonView, isChecked)
    current_profile = app_delegate.current_profile
    current_profile.touch_id_active = isChecked
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.update_resource current_profile
  end
  
  def resource_updated (profile)
    app_delegate.send("set_#{profile.type.downcase}_profile",profile)
  end
  
  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  
  def onClick(button)
    super(button)
  end
  
end