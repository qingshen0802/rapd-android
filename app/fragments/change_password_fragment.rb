class ChangePasswordFragment < Android::Support::V4::App::Fragment
  
  include BaseView
  include FragmentManager
  
  attr_accessor :profile

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
  def get_title
    get_string('change_pw_title')
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def load_views
    self.outlets['save_button'].addTarget(self, action: 'change_password')
  end
  
  def change_password
    user = self.current_user
    user.password = self.outlets["type_new_password_edit"].text.toString
    user.password_confirmation = self.outlets["confirm_password_edit"].text.toString
    
    @dialog = Utils.loading_dialog(getActivity)
    
    user_manager = UserManager.shared_manager
    user_manager.delegate = self
    user_manager.update_resource(user)
  end
  
  def onClick(button)
    super(button)
  end
  
  def resource_updated(resource)
    @dialog.dismiss
    
    app_delegate.set_user(nil)
    
    Utils.show_dialog(getActivity, "Senha Alterada", "Sua senha foi alterada com sucesso")
    
    getActivity.present_main
  end
  
  def resource_update_failed
    @dialog.dismiss
  end

end
