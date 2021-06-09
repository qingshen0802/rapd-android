class SettingsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    rows = load_table_data[:rows]
    rows << company_profile_cell if app_delegate.current_profile.type == "Company"
    adapter = ProfileAdapter.new(self, rows)
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    "Configurações"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def load_table_data
    {rows: [
        {cell_type: "icon_title_subtitle", icon: "settings_security_icon", title: "Segurança", subtitle: "Deixe sua conta mais segura", disclosure: true, action: "security_settings"},
        {cell_type: "icon_title_subtitle", icon: "settings_notifications_icon", title: "Notificações", subtitle: "Receba alertas sobre eventos", disclosure: true, action: "notification_settings"},
        # {cell_type: "icon_title_subtitle", icon: "settings_automatic_bonus_icon", title: "Bonificação Automática", subtitle: "Veja se você está sendo bonificado", disclosure: true, action: "bonus_settings"},
        {cell_type: "icon_title_subtitle", icon: "settings_coupon_icon", title: "Cupons de Crédito", subtitle: "Resgate recompensas", disclosure: true, action: "coupons_settings"},
        {cell_type: "icon_title_subtitle", icon: "account_key_icon", title: "Redefinir senha", subtitle: "Altere sua senha de acesso", disclosure: true, action: "display_edit_password"},

      ]}
  end
  
  def company_profile_cell
    {cell_type: "icon_title_subtitle", icon: "settings_club_icon", title: "Clube de Desconto", subtitle: "Configure o clube de desconto do seu estabelecimento", disclosure: true, action: "discount_club_settings"}
  end
  
  def notification_settings (i)
    switch_to_fragment("notification_settings", with_layout: 'activity_main', container: 'main')
  end
  
  def security_settings (i)
    switch_to_fragment("security_settings", with_layout: 'activity_main', container: 'main')
  end
  
  def discount_club_settings (i)
    switch_to_fragment("discount_club_settings", with_layout: 'activity_main', container: 'main')
  end

  def display_edit_password(index)
    switch_to_fragment("change_password", container: 'main', fragment_attributes: {profile: @profile})
  end

  def coupons_settings(i)
    switch_to_fragment("coupons_settings", container: 'main', fragment_attributes: {profile: @profile, back_destination: 'settings'})
  end
#  def bonus_settings (i)
#    switch_to_fragment("bonus_settings", with_layout: 'activity_main', container: 'main')
#  end
  
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

end
