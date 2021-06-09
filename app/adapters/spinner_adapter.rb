class SpinnerAdapter < Android::Widget::BaseAdapter
  include AdapterManager
  
  attr_accessor :custom_view

  def initialize(activity, objects, custom_view = 'custom_row_spinner_item')
    self.activity = activity
    self.objects = objects
    self.custom_view = custom_view
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
    view = init_row custom_view
    object =  getItem(i)
    outlets['spinner_item_title'].text = object
    view
  end
end