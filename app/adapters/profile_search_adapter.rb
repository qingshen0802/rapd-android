class ProfileSearchAdapter < Android::Widget::BaseAdapter
  include AdapterManager
  attr_accessor :parent

  def initialize(parent, objects)
    self.parent = parent
    self.activity = parent.getActivity
    self.objects = objects
  end

  def set_data(objects)
    self.objects = objects
    notifyDataSetChanged
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
    row = getItem i
    view = init_row row[:cell_type]
    if row[:dormant]
      outlets['item_checked'].set_gone
      outlets['item_name'].text = row[:email].nil? ? row[:phone_number] : row[:email]
      outlets["item_detail"].text = "Dormant"
      view.addTarget(parent, action: "create_dormant_transaction", i)
    else
      outlets['item_checked'].set_gone
      outlets['item_name'].text = row[:full_name]
      outlets['item_detail'].text = row[:username]
      Utils.insert_photo_for_circle_view(activity, {photo: row[:photo_url], image_view: outlets['item_photo']})
      view.addTarget(parent, action: "add_profile_to_transaction", i)
    end
    view
  end
end