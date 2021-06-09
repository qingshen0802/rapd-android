class EditPhoneFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    outlets['my_number'].text = Utils.format_phone_number(current_user.phone_number)
    
    outlets['change_number'].addTarget(self, action: 'save')
  end
  
  def get_title
    "Meu telefone"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def onClick(button)
    super button
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
  def save
    user = current_user
    user.phone_number = outlets["my_number"].text.toString

    @dialog = Utils.loading_dialog(getActivity)
    user_manager = UserManager.shared_manager
    user_manager.delegate = self
    user_manager.update_resource(user)
  end
  
  def resource_updated(user)
    app_delegate.set_user(user)
    
    @dialog.dismiss
    getFragmentManager().popBackStack()
  end
  
end
