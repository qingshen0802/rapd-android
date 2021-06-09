class ForgotPasswordFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('forgot_password_title')
  end
  
  def load_views
    self.outlets['redefine_button'].addTarget(self, action: 'redefine')
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end

    true
  end
  
  def redefine
    @dialog = Utils.loading_dialog(getActivity)
    @phone_number = self.outlets['phone_number'].text.toString
    
    user_manager = UserManager.shared_manager
    user_manager.delegate = self
    user_manager.reset_password(@phone_number)
  end
  
  def redefined_password(response)
    @dialog.dismiss
    
    if response.status >= 400
      Utils.show_dialog(getActivity, "Erro", "Ocorreu um erro, favor conferir os dados")
    else
      Utils.show_dialog(getActivity, "SMS enviado", "SMS enviado com código de confirmação")
      
      p response.body["user"]
      
      switch_to_fragment('verify_code', container: 'welcome', fragment_attributes: {password_reset: true, user_id: response.body["user"]["id"], phone_ending_number: @phone_number[-4,4]})
    end
  end

  def onClick(button)
    super(button)
  end

end