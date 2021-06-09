class ContactListAdapter < Android::Widget::BaseAdapter
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
    if row[:cell_type] == "divider"
      view =	init_row  "list_view_separator"
    else
      view = init_row  row[:cell_type]
      outlets['username'].text = row[:username]
      outlets['full_name'].text = row[:full_name]
      Utils.insert_photo_for_circle_view(activity, {photo: row[:image], image_view: outlets['contact_photo']}) unless row[:image] == "/images/original/missing.png"
      outlets['heading_container'].text = row[:heading] unless row[:heading].nil?
    end
    view
  end
  
end