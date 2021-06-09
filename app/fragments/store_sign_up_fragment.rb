class StoreSignUpFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    
    @profile = Profile.new
    
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end    

  def get_title
    get_string('new_shop')
  end

  def load_views
    self.outlets['next_button'].addTarget(self, action: 'finish_signup')
    self.outlets['accept_text_view'].addTarget(self, action: 'terms_of_use')
    self.outlets['shop_image'].addTarget(self, action: 'select_image')
  end

  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end

    true
  end
  
  def finish_signup
    if self.outlets['terms_check_box'].isChecked
      @dialog = Utils.loading_dialog(getActivity())
      
      if @profile.new_record?
        create_profile        
      else
        update_profile
      end
    else
      Utils.show_dialog(getActivity, "Termos de Uso", "Aceite os termos de uso para poder continuar")
    end
  end
  
  def create_profile
    profile = Profile.new({
      type: 'Company',
      username: self.outlets["company_name"].text.toString,
      full_name: self.outlets["fantasy_name"].text.toString,
      document_id: self.outlets["company_number"].text.toString,
      email: self.outlets["email_address_text"].text,
      accepts_terms: "1"
    })
    
    profile.photo = @photo

    profile_manager = CompanyManager.shared_manager
    profile_manager.delegate = self
    profile_manager.create_resource(profile)
  end
  
  def resource_created (business_profile)
    @dialog.dismiss
    app_delegate.set_company_profile business_profile
    app_delegate.set_current_profile_id app_delegate.secondary_profile.remote_id
    getActivity.init_profile_information
    switch_to_fragment("profile", with_layout: 'activity_main', container: 'main')
  end
  
  def update_profile
    profile.full_name = self.outlets["name_field"].text
    profile.is_legal_represented = self.underage ? "1" : "0",

    profile.photo = @photo

    profile_manager = BusinessManager.shared_manager
    profile_manager.delegate = self
    profile_manager.update_resource(profile)
  end
  
  def terms_of_use
    switch_to_fragment('terms_of_use', container: 'welcome')
  end

  def onClick(button)
    super(button)
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
      
      self.outlets['shop_photo_iv'].setImageBitmap(bitmap)
    end
  end

end
