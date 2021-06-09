class DocumentAdapter < Android::Widget::BaseAdapter
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
    when "document_status"
      view = init_row 'document_status'
      
      outlets['document_status'].text = row[:title]
      outlets['document_action'].text = row[:subtitle]
      
      insert_photo(image_view: outlets['ic_status'], photo: row[:status_icon])
    end
    
    view
  end
  
end