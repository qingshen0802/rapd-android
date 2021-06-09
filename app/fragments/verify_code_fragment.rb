class VerifyCodeFragment < Android::Support::V4::App::Fragment
  
  include BaseView
  include FragmentManager
  
  attr_accessor :password_reset, :user_id, :user_token, :phone_ending_number

  def onCreateView(inflater, container, savedInstanceState)
    super
    
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string('verify_code')
  end
  
  def load_views
    self.outlets['sms_not_received'].addTarget(self, action: 'resend_sms')
    self.outlets['sms_not_received'].text = get_string('no_receive_sms').html_safe
    self.outlets['confirm'].addTarget(self, action: 'next')
    self.outlets['code_verify_send_sms'].text = get_string('send_sms').gsub('%s', phone_ending_number)
  end

  def onClick(button)
    super(button)
  end

  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end

  def resend_sms
    manager = UserManager.shared_manager
    manager.delegate = self
    manager.resend_sms(user_id, user_token)
  end
  
  def resent_sms(response)
    Utils.show_dialog(getActivity, "SMS Enviado", "Novo SMS enviado com código de confirmação")
  end

  def next
    sms_code = self.outlets['confirmation_code'].text.toString
    
    if sms_code.length > 0
      @dialog = Utils.loading_dialog(getActivity)
      
      user_manager = UserManager.shared_manager
      user_manager.delegate = self
      
      if password_reset
        user_manager.reset_password_confirm(sms_code, user_id)
      else
        user_manager.confirm_sms(sms_code)
      end
    else
      Utils.show_dialog(getActivity, "Erro", "Insira o código que recebeu via SMS.")
    end
  end
  
  def confirmed_sms(response)
    @dialog.dismiss
    
    if response.status >= 400
      Utils.show_dialog(getActivity, "Erro", "Código inválido, tente novamente")
    else
      app_delegate.set_user(response.body["user"].merge(remote_id: response.body["user"]["id"]))
      app_delegate.set_profile_ids(response.body["user"]["profile_ids"])
      getActivity.present_main
    end
  end
  
  def reseted_password(response)
    @dialog.dismiss
    
    if response.status >= 400
      Utils.show_dialog(getActivity, "Erro", "Código inválido, tente novamente")
    else
      app_delegate.set_user(response.body["user"].merge(remote_id: response.body["user"]["id"]))
      switch_to_fragment('change_password', container: 'welcome')
    end
  end

end