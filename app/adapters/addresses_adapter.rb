class AddressesAdapter < Android::Widget::BaseAdapter
  include AdapterManager

  def initialize(fragment, objects)
    self.fragment = fragment
    self.activity = fragment.getActivity
    self.objects = objects
  end

  def getCount
    objects.length
  end

  def getItem(i)
    objects[i]
  end

  def getItemId(i)
    i
  end

  def getView(i, view, view_group)
    row = getItem(i)
    
    case row[:cell_type]
    when "title_subtitle"
      view = init_row 'title_subtitle'
      
      outlets['address_name'].text = row[:title]
      outlets['address_street'].text = row[:subtitle]
      
      view.addTarget(fragment, action: row[:action], row[:action_param])
    end
    
    view
  end
  
end