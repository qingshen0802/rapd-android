module FragmentManager

  attr_accessor :outlets, :back_destination
  
  def fragmentOnCreateView(inflater, container, savedInstanceState, search_bar_layout="action_bar")
    view = inflater.inflate(find_layout(fragment_layout_name), container, false)
    unless nested_fragment?
      if has_actionbar? 
        getActivity().getSupportActionBar.show
        getActivity.create_drawer_toggle if has_drawer_toggle?
        getActivity.create_back_button if has_back_arrow?
        getActivity.toolbar.getMenu().clear() if getActivity.toolbar
        
        getActivity.set_toolbar_title(get_title)
        getActivity.set_toolbar_menu(get_menu("action_bar_#{self.class.to_s.gsub('Fragment', '').underscore}_menu")) if has_actionbar_menu?
      else
        getActivity().getSupportActionBar().hide()
      end
    end
    
    self.outlets = OutletSet.new(package_name: getActivity().packageName, parent: self, view: view)
    load_views
    
    view
  end
  
  def get_title
    "Undefined"
  end

  def has_actionbar?
    true
  end
  
  def has_drawer_toggle?
    true
  end
  
  def has_back_arrow?
    false
  end
  
  def has_actionbar_menu?
    false
  end
  
  def nested_fragment?
    false
  end

  def fragment_layout_name
    "fragment_#{self.class.to_s.gsub('Fragment', '').underscore}"
  end  
  
  def load_views
  end

  def present_fragment(fragment_name, options = {})
    layout_id = options[:with_layout]
    container_id = options[:into_container]
    
    self.contentView = find_layout(layout_id)
    fragment = "#{fragment_name}_fragment".camelize.constantize.new
    getActivity.current_fragment = fragment
    
    ft = getSupportFragmentManager().beginTransaction()
    ft.replace(find("#{container_id}_container"), fragment, fragment_name)
    ft.commit
  end
  
  def switch_to_fragment(fragment_name, options = {})
    container = options[:container]
    fragment = "#{fragment_name}_fragment".camelize.constantize.new
    getActivity.current_fragment = fragment
    if options[:fragment_attributes]
      options[:fragment_attributes].map do |k, v|
        fragment.send("#{k}=", v)
      end
    end

    
    ft = getActivity().getSupportFragmentManager().beginTransaction()
    if options[:add]
      ft.add(find("#{container}_container"), fragment, fragment_name)
    else
      ft.replace(find("#{container}_container"), fragment, fragment_name)
    end
    ft.addToBackStack(fragment_name)
    ft.commit    
  end

  def go_back
    getActivity().go_back
  end

  def go_back_to_fragment(back_destination)
    getActivity.go_back_to_fragment back_destination
  end
  
  def packageName
    if activity?
      super
    else
      getActivity().packageName
    end
  end
  
  def activity?
    self.is_a?(Android::Support::V7::App::AppCompatActivity)
  end
  
  def get_actionbar_view
    resId = resources.getIdentifier("action_bar_container", "id", packageName);
    getActivity.findViewById(resId);
  end
  
  def find(id)
    resources.getIdentifier(id, 'id', packageName)
  end
  
  def find_layout(layout_id)
    resources.getIdentifier(layout_id, 'layout', packageName)
  end
  
  def get_string(string_id)
    getString(resources.getIdentifier(string_id, 'string', packageName))
  end
  
  def get_array(array_id)
    resources.getStringArray(resources.getIdentifier(array_id, 'array', packageName))
  end
  
  def get_color(color_id)
    resources.getIdentifier(color_id, 'color', packageName)
  end
  
  def get_menu(menu_id)
    resources.getIdentifier(menu_id, 'menu', packageName)
  end
  
  def get_drawable(drawable_id)
    resources.getIdentifier(drawable_id, 'drawable', packageName)
  end
  
  def select_image
    Utils.select_image_dialog(getActivity, self)
  end
  
end