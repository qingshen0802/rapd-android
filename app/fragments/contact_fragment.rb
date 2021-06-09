class ContactFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    adapter = ProfileAdapter.new(self, load_table_data.first[:rows])
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    "Tratto"
  end

  def has_actionbar_menu?
    true
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
        {cell_type: "icon_title_subtitle", icon: 'profile_help_icon', title: "Ajuda", subtitle: "Está com problemas? Nós te ajudamos", disclosure: true, action: "display_help"},
        {cell_type: "icon_title_subtitle", icon: "contact_about_icon", title: "Sobre Nós", subtitle: "Saiba um pouco sobre nós", disclosure: true, action: "about"},
        {cell_type: "icon_title_subtitle", icon: "contact_talk_icon", title: "Fale Conosco", subtitle: "Problemas? Envie-nos uma mensagem", disclosure: true, action: "talk"},
      ]}
    ]
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

end
