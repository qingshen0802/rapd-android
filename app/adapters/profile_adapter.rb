class ProfileAdapter < Android::Widget::BaseAdapter
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
    when "profile_picture"
      view = init_row 'profile_picture'
      insert_photo(image_view: outlets['my_account_user_image'], photo: row[:profile_photo])
      view.addTarget(fragment, action: row[:action], i)
    when "profile_top"
      view = init_row 'custom_row_profile_top'
      
      outlets['profile_nick'].text = row[:profile_username]
      outlets['profile_name'].text = row[:profile_name]
      
      insert_photo(image_view: outlets['profile_image'], photo: row[:profile_photo])
    when "icon_title_subtitle"
      view = init_row 'custom_row_profile'
      
      outlets['option_name'].text = row[:title]
      outlets['option_info'].text = row[:subtitle]
      
      insert_photo(image_view: outlets['option_image'], photo: asset(row[:icon]))
      
      view.addTarget(fragment, action: row[:action], i)
    end
    view
  end
  
end