class ContactListContentFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :type
  
  PHONE_NUMBER = "data1"
  PHONE_TYPE = "data2"
  PHONE_CONTACT_ID = "contact_id"
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    if "#{self.type}" == "Telephone"
      load_contacts
    else
      manager = "#{self.type}Manager".constantize.shared_manager 
      manager.delegate = self
      manager.fetch_all({profile_id:  app_delegate.current_profile_id})
    end
  end
  
  def items_fetched(content)
    content_type = self.type == "Contact" ? "contact" : "profile"
    contacts = content.map{|content| content.send(content_type)}
    rows = cells_for_contacts(contacts)
    adapter = ContactListAdapter.new(self,rows)
    outlets['contact_list'].adapter = adapter
  end
  
  def load_contacts
    contacts = []
    if Android::Support::V4::Content::ContextCompat.checkSelfPermission(getActivity(),contact_permission) != permission_granted
      request_permission
      return
    else
      resolver = getActivity.getBaseContext.getContentResolver
      cur = resolver.query(Android::Provider::ContactsContract::Contacts::CONTENT_URI,nil, nil, nil, nil)
      return if cur.getCount() == 0
      nameFieldColumnIndex = cur.getColumnIndex(contact_display_name)
      numberFieldColumnIndex = cur.getColumnIndex(contact_picture)
      while cur.moveToNext() && contacts.size < 10 do
        contact = {}
        contact['full_name'] = cur.getString(nameFieldColumnIndex)
        contact['username'] = cur.getString(nameFieldColumnIndex)
        photo_url = cur.getString(numberFieldColumnIndex)
        contact['photo_url'] = photo_url.nil? ? "/images/original/missing.png" : photo_url
        contact['phone_number'] = number_for_contact(contact['name'])
        contacts << contact
      end
      adapter = ContactListAdapter.new(self,cells_for_contacts(contacts)) 
      outlets['contact_list'].adapter = adapter
    end
  end
  
  def cells_for_contacts(contacts)
    rows = []
    profiles = contacts.sort_by{|contact| contact["full_name"].downcase}
    current_letter = nil
    profiles.each do |contact|
      contact_letter =  contact["full_name"][0].upcase
      cell = {cell_type: "custom_row_contact", image: contact["photo_url"], full_name: contact["full_name"], username:"@#{contact['username']}"}
      if contact_letter != current_letter
        rows << {cell_type: "divider"} unless current_letter.nil?
        cell = cell.merge({heading: contact_letter})
        current_letter = contact_letter
      end
      rows << cell
    end
    rows
  end
  
  def number_for_contact (name)
    selection = "DISPLAY_NAME = '#{name}'"
    phone_cursor = context.getContentResolver.query(phone_number_constant, nil, selection, nil, nil)
    while phone_cursor.moveToNext() do
      number = phone_cursor.getString(phone_cursor.getColumnIndex(PHONE_NUMBER))
    end
    phone_cursor.close
    number
  end
  
  def phone_number_constant
    Android::Net::Uri.parse("content://com.android.contacts/data/phones")
  end
  
  def contact_display_name
    Android::Provider::ContactsContract::Contacts::DISPLAY_NAME
  end
  
  def contact_picture
    Android::Provider::ContactsContract::ContactsColumns::PHOTO_URI
  end
  
  def request_permission
    Android::Support::V4::App::ActivityCompat.requestPermissions(getActivity(),["#{contact_permission}".to_java],42);
  end
  
  def contact_permission
    Android::Manifest::Permission::READ_CONTACTS
  end
  
  def permission_granted
    Android::Content::Pm::PackageManager::PERMISSION_GRANTED
  end
  
  def nested_fragment?
    true
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
end