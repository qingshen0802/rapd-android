class EmployeeFragment < Android::Support::V4::App::Fragment 
  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    view = fragmentOnCreateView(inflater, container, savedInstanceState)
    view
  end

  def load_views
    manager = ContactManager.shared_manager 
    manager.delegate = self
    manager.fetch_all({profile_id:  app_delegate.current_profile_id, is_employee: true})
  end
  
  def items_fetched(content)
    rows = content.map{|contact| to_cell(contact.profile)}
    adapter = ContactListAdapter.new(self,rows)
    outlets['employee_list'].adapter = adapter
  end
  
  def to_cell (profile)
    {cell_type: "custom_row_employee", image: profile["photo_url"], username:"@#{profile['username']}"}
  end

  def get_title
    get_string("employee_list_title")
  end
  
  def onClick(button)
      super(button)
  end  
  
  def has_drawer_toggle?
    false
  end
  
  def has_back_arrow?
    true
  end
  
  def has_actionbar_menu?
    true
  end
  

end