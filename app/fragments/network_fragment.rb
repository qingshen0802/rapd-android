class NetworkFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    rows = load_table_data.first[:rows] 
    rows <<  company_cell  if self.profile.type == "Company"
    adapter = ProfileAdapter.new(self, rows)
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    "Meus Contatos"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def company_cell
    {cell_type: "icon_title_subtitle", icon: "network_employees_icon", title: "Meus Funcionários", subtitle: "Gerencie os funcionários do seu negócio", disclosure: true, action: "manageEmployees"}
  end
  
  def load_table_data
    [
      {rows: [
      # {cell_type: "icon_title_subtitle", icon: "network_contacts_icon", title: "Meus Contatos", subtitle: "Seus amigos que estão no aplicativo", disclosure: true, action: "manageContacts"},
      # {cell_type: "icon_title_subtitle", icon: "network_favorite_icon", title: "Meus Favoritos", subtitle: "Seus amigos favoritos no aplicativo", disclosure: true, action: "manageFavorites"},
      # {cell_type: "icon_title_subtitle", icon: "network_lists_icon", title: "Listas de Pagamentos", subtitle: "Gerencie listas com várias pessoas", disclosure: true, action: "manageLists"},
        {cell_type: "icon_title_subtitle", icon: "network_invite_icon", title: "Convide Seus Amigos", subtitle: "Compartilhe o Tratto com seus amigos", disclosure: true, action: "share"},
        {cell_type: "icon_title_subtitle", icon: "network_referrals_icon", title: "Meus Indicados", subtitle: "Pessoas indicadas por você que se cadastraram", disclosure: true, action: "manageReferrals"},
      ]}
    ]
  end
  
  def onClick(button)
    super button
  end
  
 # def manageContacts(i)
 #   switch_to_fragment("contact_list", with_layout: 'activity_main', container: 'main')
 # end 
  
  def manageEmployees(i)
    switch_to_fragment("employee", with_layout: 'activity_main', container: 'main')
  end

  def manageReferrals
    
      #should be implemented
  end
  
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end

end
