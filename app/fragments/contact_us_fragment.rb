class ContactUsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    adapter = ProfileAdapter.new(self, load_table_data.first[:rows])
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    get_string('about_us')
  end
  
  def load_table_data
    [
      {rows: [
        {cell_type: "icon_title_subtitle", icon: 'profile_help_icon', title: "Ajuda", subtitle: "Está com problemas? Nós te ajudamos", disclosure: true, action: "display_help"},
        {cell_type: "icon_title_subtitle", icon: 'info_icon', title: "Sobre nós", subtitle: "Saiba um pouco sobre a Tratto", disclosure: true, action: "display_about"},
        {cell_type: "icon_title_subtitle", icon: 'chat_icon', title: "Fale Conosco", subtitle: "Problemas? Entre em contato", disclosure: true, action: "display_contact_details"}
      ]}
    ]
  end

  def display_contact_details(i)
    switch_to_fragment("contact_details", container: "main")
  end  

  def display_help(i)
    switch_to_fragment("help", container: "main")
  end

  def display_about(i)
    switch_to_fragment("about_us", container: "main")
  end

  def has_back_arrow?
    true    
  end  
  
  def onClick(button)
    super button
  end
  
end