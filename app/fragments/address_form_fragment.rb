class AddressFormFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :address, :cities
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    
    self.address = Address.new if !self.address
    
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    address.new_record? ? "Novo endereço" : "Alterar endereço"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def load_views
    outlets['insert_identification_name'].text = address.name
    outlets['insert_zip'].text = address.postal_code
    outlets['insert_street_avenue'].text = address.address_line_1
    outlets['insert_number'].text = address.address_line_2
    outlets['insert_supplement'].text = address.address_line_3
    outlets['insert_neighborhood'].text = address.borough
      
    data = Utils.read_json_file_as_hash(getActivity, "estados-cidades.json")
    
    states = data["estados"].collect{|state| state["sigla"]}
    self.cities = {}
    data["estados"].each{|state| self.cities[state["sigla"]] = state["cidades"]}
    
    states_adapter = Android::Widget::ArrayAdapter.new(getActivity, Android::R::Layout::Simple_spinner_item, states)
    states_adapter.setDropDownViewResource(Android::R::Layout::Simple_spinner_dropdown_item)
    outlets['insert_state'].adapter = states_adapter
    outlets['insert_state'].setOnItemSelectedListener(ItemSelectedListener.new(self, "set_state"))
    
    if address.state
      state_selection = states.index(address.state)
      outlets['insert_state'].selection = state_selection if state_selection
    end
    
    load_cities_adapter
    
    outlets['toggle_alert'].checked = address.default_address
    
    outlets['continue_button'].addTarget(self, action: 'save')
    outlets['delete_button'].addTarget(self, action: 'delete')
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
  
  def save
    self.address.name = self.outlets["insert_identification_name"].text.toString
    self.address.address_line_1 = self.outlets["insert_street_avenue"].text.toString
    self.address.address_line_2 = self.outlets["insert_number"].text.toString
    self.address.address_line_3 = self.outlets["insert_supplement"].text.toString
    self.address.borough = self.outlets["insert_neighborhood"].text.toString
    self.address.city = self.outlets["insert_city"].getSelectedItem.toString
    self.address.state = self.outlets["insert_state"].getSelectedItem.toString
    self.address.postal_code = self.outlets["insert_zip"].text.toString
    self.address.default_address = self.outlets['toggle_alert'].isChecked
    self.address.profile_id = self.profile.remote_id
    
    # Check if all fields were filled
    if self.address.name != "" && self.address.address_line_1 != "" && self.address.address_line_2 != "" && self.address.borough != "" && self.address.postal_code != ""
      @dialog = Utils.loading_dialog(getActivity)
      address_manager = AddressManager.shared_manager
      address_manager.delegate = self

      if address.new_record?
        address_manager.create_resource(address)
      else
        address_manager.update_resource(address)
      end
    else
      Utils.show_dialog(getActivity, "Alerta", "Por favor preencha todos os campos.")
    end
  end
  
  def toggle_default_address(switch)
    self.address.default_address = switch.isOn
  end
  
  def resource_created(address)
    @dialog.dismiss
    
    Utils.show_dialog(getActivity, "Endereço Criado", "Seu endereço foi adicionado com sucesso")
    
    getFragmentManager().popBackStack()
  end
  
  def resource_creation_failed
    @dialog.dismiss
  end
  
  def resource_updated(address)
    @dialog.dismiss
    
    Utils.show_dialog(getActivity, "Endereço Atualizado", "Seu endereço foi atualizado com sucesso")  
    
    getFragmentManager().popBackStack()
  end
  
  def resource_update_failed
    @dialog.dismiss
  end
  
  def set_state(pos)
    load_cities_adapter
  end
  
  def load_cities_adapter
    cities_adapter = Android::Widget::ArrayAdapter.new(getActivity, Android::R::Layout::Simple_spinner_item, self.cities[outlets['insert_state'].getSelectedItem])
    cities_adapter.setDropDownViewResource(Android::R::Layout::Simple_spinner_dropdown_item)
    outlets['insert_city'].adapter = cities_adapter
    
    if self.address.city
      city_selection = self.cities[outlets['insert_state'].getSelectedItem].index(self.address.city)
      outlets['insert_city'].selection = city_selection if city_selection
    end
  end
  
  def delete
    @dialog = Utils.loading_dialog(getActivity)
    address_manager = AddressManager.shared_manager
    address_manager.delegate = self
    address_manager.delete_resource(address)
  end
  
  def resource_deleted
    @dialog.dismiss
    Utils.show_dialog(getActivity, "Endereço removido", "Seu endereço foi removido com sucesso")
    getFragmentManager().popBackStack()
  end
  
  def resource_delete_failed
    @dialog.dismiss
  end
  
end
