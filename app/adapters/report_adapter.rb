class ReportAdapter < Android::Widget::BaseAdapter
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
    outlets['report_title'].text = row[:report_title]
    outlets['report_text'].text = row[:report_text]
  
    view
  end
end