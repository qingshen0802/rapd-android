class WalletAdapter < Android::Widget::BaseAdapter
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

    outlets["wallet_container"].getBackground.mutate.setColor(Android::Graphics::Color.parseColor("##{row[:color]}"))
    outlets['name'].text = row[:name]
    outlets["amount"].text = row[:balance]
    if row[:is_default]
      outlets["is_default"].set_visible
      outlets["is_default"].setTextColor(Android::Graphics::Color.parseColor("##{row[:color]}"))
    end

    view.addTarget(parent, action: row[:action], i)

    view
  end
end