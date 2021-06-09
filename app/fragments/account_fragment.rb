class AccountFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    profile_photo = @profile.photo_url if !@profile.nil? && !@profile.photo_url.nil?
    profile_photo = "https://graph.facebook.com/#{current_user.facebook_id}/picture?width=9999" if (!current_user.facebook_id.nil? && profile_photo.to_s.length == 0) || profile_photo =~ /missing/

    Utils.insert_photo_for_circle_view(getActivity, {photo: profile_photo, image_view: outlets['my_account_user_image']})
    outlets['change_photo_icon'].setOnClickListener(self)

    adapter = ProfileAdapter.new(self, load_table_data.first[:rows])
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    "Meu Perfil"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def load_table_data
    [
      {rows: [
        {cell_type: "icon_title_subtitle", icon: "account_pencil_icon", title: "Meus dados", subtitle: "Edite suas informações básicas", disclosure: true, action: "display_edit_info"},
        {cell_type: "icon_title_subtitle", icon: "account_phone_icon", title: "Meu telefone", subtitle: "Mantenha seu número de celular atualizado", disclosure: true, action: "display_edit_phone"},
        {cell_type: "icon_title_subtitle", icon: "account_home_icon", title: "Meus Endereços", subtitle: "Confirme seus endereços", disclosure: true, action: "display_manage_addresses", action_param: @profile},
        {cell_type: "icon_title_subtitle", icon: "account_document_icon", title: "Meus documentos", subtitle: "Confirme sua identidade", disclosure: true, action: "display_manage_documents"},
        # {cell_type: "icon_title_subtitle", icon: "account_network_icon", title: "Redes Sociais", subtitle: "Um pouco mais sobre você", disclosure: true, action: "displaySocialNetworks"},
        {cell_type: "icon_title_subtitle", icon: "account_bank_icon", title: "Meus dados bancários", subtitle: "Informe os dados do seu banco", disclosure: true, action: "display_manage_bank_accounts"}
      ]}
    ]
  end
  
  def onClick(button)
    if button == outlets['change_photo_icon']
      select_image
    end
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end

  def onActivityResult(req_code, res_code, data)
    super
    if res_code == Android::App::Activity::RESULT_OK
      selected_image = data.getData()

      if selected_image
        bitmap = Utils.decode_sampled_bitmap_from_uri(selected_image, 500, 500, getActivity.getContentResolver)
      else
        bitmap = data.getExtras.get("data")
      end
      outlets['my_account_user_image'].setImageBitmap(bitmap)

      @attachment = Utils.create_file(getActivity, bitmap)
      update_profile_photo
    end
  end

  def update_profile_photo
    @dialog = Utils.loading_dialog(getActivity)
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.update_resource build_profile
  end

  def build_profile
    Profile.new({
                    remote_id: @profile.id,
                    photo: @attachment
                })
  end

  def resource_updated(profile)
    @dialog.dismiss
    # go_back
  end

  def resource_update_failed
    @dialog.dismiss
  end

  def display_edit_info(index)
    switch_to_fragment('edit_profile', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  def display_edit_phone(index)
    switch_to_fragment('edit_phone', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  
  def display_manage_addresses(index)
    switch_to_fragment('addresses', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  def display_manage_documents(index)
    switch_to_fragment('document_check', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  def display_manage_bank_accounts(index)
    switch_to_fragment('bank_config', container: 'main', fragment_attributes: {profile: @profile})
  end

end
