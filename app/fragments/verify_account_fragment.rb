class VerifyAccountFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end  
  
  def get_title
    get_string('phone_verify')
  end
  
  def load_views
    self.outlets['already_registered_button'].addTarget(self, action: 'already_registered')
    self.outlets['already_registered_button'].text = get_string('already_registered').html_safe
    self.outlets['to_continue'].addTarget(self, action: 'continue')
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
  def already_registered
    switch_to_fragment('sign_in', container: 'welcome')
  end
  
  def continue
    phone_number = self.outlets['cellphone_number'].text.toString
    
    if phone_number.length > 0
      @dialog = Utils.loading_dialog(getActivity())
      
      user = app_delegate.current_user
      user.phone_number = phone_number
      
      user_manager = UserManager.shared_manager
      user_manager.delegate = self
      user_manager.update_resource(user)
    else
      Utils.show_dialog(getActivity, "Erro", "Insira um número de celular válido")
    end
  end
  
  def resource_updated(resource)
    @dialog.dismiss
    
    app_delegate.set_user(resource)
    
    switch_to_fragment('verify_code', container: 'welcome', fragment_attributes: {phone_ending_number: current_user.phone_number[-4,4], user_id: current_user.remote_id, user_token: current_user.access_token})
  end
  
  def resource_update_failed
    @dialog.dismiss
  end
  
  def onClick(button)
    super(button)
  end
end