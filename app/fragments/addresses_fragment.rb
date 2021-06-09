class AddressesFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :addresses
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    load_addresses
    
    outlets['add_new_address'].addTarget(self, action: 'add_address')
  end
  
  def get_title
    "Meus endereços"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
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
  
  def load_addresses
    address_manager = AddressManager.shared_manager
    address_manager.delegate = self
    address_manager.fetch_all(profile_id: profile.remote_id)
  end
  
  def items_fetched(addresses)
    self.addresses = addresses
    
    adapter = AddressesAdapter.new(self, address_rows)
    outlets['address_list'].adapter = adapter
  end
  
  def address_rows
    if self.addresses.nil? || self.addresses.to_a.count == 0
      []
    else
      addresses.map{|address|
        {cell_type: "title_subtitle", title: address.name, subtitle: address.short_address, id: address.remote_id, action: "select_address", action_param: address, disclosure: true}
      }
    end
  end
  
  def select_address(address)
    switch_to_fragment('address_form', container: 'main', fragment_attributes: {profile: @profile, address: address})
  end
  
  def add_address
    switch_to_fragment('address_form', container: 'main', fragment_attributes: {profile: @profile})
  end
  
end
