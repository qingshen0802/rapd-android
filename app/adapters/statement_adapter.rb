class StatementAdapter < Android::Widget::BaseAdapter
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
    row =  getItem(i)
    view = init_row row[:cell_type]
    outlets['statement_month'].text = row[:month_name]
    view.addTarget(fragment, action: row[:action], i)
  
    view
  end
end