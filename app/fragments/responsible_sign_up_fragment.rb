class ResponsibleSignUpFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    
    view = fragmentOnCreateView(inflater, container, savedInstanceState)
    
    self.profile = app_delegate.current_profile
    
    view
  end  
    
  def get_title
    get_string('responsible_signup')
  end
  
  def load_views
    self.outlets['sign_up_button'].addTarget(self, action: "sign_up")
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
  def sign_up
    self.profile.legal_representer_name = self.outlets["type_responsible_name"].text.toString
    self.profile.legal_representer_document_id = self.outlets["type_responsible_cpf"].text.toString
    self.profile.legal_representer_email = self.outlets["type_responsible_email"].text.toString
    
    manager = PeopleManager.shared_manager
    manager.delegate = self
    manager.update_resource(profile)
  end
  
  def resource_updated(profile)
    app_delegate.set_current_profile(profile)
    
    getActivity.present_main
  end
  
  def onClick(button)
    super(button)
  end
end
