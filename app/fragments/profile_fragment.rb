class ProfileFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    load_profile
  end
  
  def get_title
    "Perfil Usuario"
  end
  
  def load_table_data
    profile_photo = @profile.photo_url if !@profile.nil?  && !@profile.photo_url.nil?
    profile_photo = "https://graph.facebook.com/#{current_user.facebook_id}/picture?width=9999" if (!current_user.facebook_id.nil? && profile_photo.to_s.length == 0) || profile_photo =~ /missing/

    [
      {rows: [
        {cell_type: "profile_top", profile_name: @profile.full_name, profile_username: "@#{@profile.username}", profile_photo: profile_photo, show_gear: true},
        {cell_type: "icon_title_subtitle", icon: 'profile_account_icon', title: "Meu perfil", subtitle: "Dados pessoais, endereço, etc", disclosure: true, action: "display_account"},
      #  {cell_type: "icon_title_subtitle", icon: 'profile_network_icon', title: "Meus contatos", subtitle: "Suas indicações, funcionários, etc", disclosure: true, action: "display_network"},
        {cell_type: "icon_title_subtitle", icon: 'profile_money_icon', title: "Operações financeiras", subtitle: "Carregar dinheiro, pagar contas, etc", disclosure: true, action: "display_wallet_actions"},
        {cell_type: "icon_title_subtitle", icon: 'profile_settings_icon', title: "Configurações", subtitle: "Altere suas configurações de segurança, etc", disclosure: true, action: "display_settings"},
        {cell_type: "icon_title_subtitle", icon: 'profile_rapd_icon', title: "Tratto", subtitle: "Maiores informações, ajuda, etc", disclosure: true, action: "display_contact"}
      ]}
    ]
  end
  
  def load_profile
    @profile = Profile.new
    
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.fetch(app_delegate.current_profile_id)
  end
  
  def item_fetched(profile)
    @profile = profile
    
    adapter = ProfileAdapter.new(self, load_table_data.first[:rows])
    outlets['options_list'].adapter = adapter
  end
  
  def onClick(button)
    super button
  end
  
  def display_account(index)
    switch_to_fragment('account', container: 'main', fragment_attributes: {profile: @profile})
  end
  
#  def display_network(index)
#    switch_to_fragment('network', container: 'main', fragment_attributes: {profile: @profile})
#  end
  
  def display_wallet_actions(index)
    switch_to_fragment('manage_wallet', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  def display_settings(index)
    switch_to_fragment('settings', container: 'main', fragment_attributes: {profile: @profile})
  end
  
  # def display_help(index)
  #   switch_to_fragment('help', container: 'main')
  # end
  
  def display_contact(index)
    switch_to_fragment('contact_us', container: 'main')
  end

end
