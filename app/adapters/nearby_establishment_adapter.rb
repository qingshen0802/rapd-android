class NearbyEstablishmentAdapter < Android::Widget::BaseAdapter
  include AdapterManager
  attr_accessor :parent

  def initialize(parent, objects)
    self.parent = parent
    self.activity = parent.getActivity
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
    row = getItem i
    view = init_row row[:cell_type]

    outlets['item_checked'].set_gone
    outlets['item_name'].text = row[:name]
    outlets['item_detail'].text = row[:distance]
    Utils.insert_photo_for_circle_view(activity, {photo: row[:photo_url], image_view: outlets['item_photo']}) unless row[:photo_url] == "/images/original/missing.png"
    view.addTarget(parent, action: "pay_establishment", i)
    view
  end

  def set_border_color(i, view)
    if i.odd?
      outlets["bottom_border"].setBackgroundColor(get_color("pale_grey"))
    end
  end
end