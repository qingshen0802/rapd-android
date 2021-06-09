class SignUpFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end    
  
  def get_title
    get_string('sign_up')
  end
  
  def onClick(button)
    super(button)
  end  
  
  def load_views
    if(app_delegate.logged_in?) 
      self.outlets['email_address'].text = 
        activity.app_delegate.current_user.email
      self.outlets['user_full_name'].text = 
        activity.app_delegate.current_user.name
    end 
    self.outlets['sign_up_button'].addTarget(self, action: 'sign_up')
    self.outlets['accept_text_view'].addTarget(self, action: 'show_terms')
    self.outlets['sign_up_image'].addTarget(self, action: 'select_image')
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    true
  end
  
  def sign_up
    if self.outlets['terms_check_box'].isChecked
      @dialog = Utils.loading_dialog(getActivity())
      
      user = User.new
      user.email = self.outlets['email_address'].text.toString
      user.password = self.outlets['password'].text.toString
      user.password_confirmation = self.outlets['confirm_password'].text.toString
      if(app_delegate.logged_in?)
        user.facebook_token = app_delegate.current_user.facebook_token
        user.facebook_id = app_delegate.current_user.facebook_id 
      end   
      
      manager = UserManager.shared_manager    
      manager.delegate = self
      manager.create_resource(user)
    else
      Utils.show_dialog(getActivity, "Termos de Uso", "Aceite os termos de uso para poder continuar")
    end    
  end
  
  def show_terms
    switch_to_fragment('terms_of_use', container: 'welcome')
  end
  
  def resource_created(resource)
    if resource.is_a?(User)
      user_created(resource)
    elsif resource.is_a?(Profile)
      profile_created(resource)
    elsif resource.is_a?(UserDevice)
      user_device_created(resource)
    end
  end
  
  def resource_creation_failed

  end
  
  def user_created(user)
    app_delegate.set_user(user)
    create_profile    
  end
  
  def profile_created(profile)
    @profile = profile
    app_delegate.set_current_profile(profile)
    
    @dialog.dismiss
    
    if self.outlets['under_16_check_box'].isChecked()
      switch_to_fragment('responsible_sign_up', container: 'welcome')
    else
      switch_to_fragment('verify_account', container: 'welcome')
    end
  end
  
  def create_profile
    profile = Profile.new({
      type: 'Person',
      username: self.outlets['user_name'].text.toString,
      full_name: self.outlets['user_full_name'].text.toString,
      document_id: self.outlets['cpf_number'].text.toString,
      user_id: app_delegate.current_user.remote_id,
      email: self.outlets['email_address'].text.toString,
      is_legal_represented: self.outlets['under_16_check_box'].isChecked() ? "1" : "0",
      accepts_terms: "1"
    }) 
    
    profile.photo = @photo
    
    profile_manager = PeopleManager.shared_manager
    profile_manager.delegate = self
    profile_manager.create_resource(profile)
  end
  
  def onActivityResult(requestCode, resultCode, data)
    super

    if resultCode == Android::App::Activity::RESULT_OK
      selected_image = data.getData()
      
      if selected_image
        bitmap = Utils.decode_sampled_bitmap_from_uri(selected_image, 500, 500, getActivity.getContentResolver)
      else
        bitmap = data.getExtras.get("data")
      end
      
      @photo = Utils.create_file(getActivity, bitmap)
      
      self.outlets['user_photo_iv'].setImageBitmap(bitmap)
    end
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
end
