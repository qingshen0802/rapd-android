class ShopImageViewPagerAdapter < Android::Support::V4::View::PagerAdapter 
  
  include AdapterManager
  
  def initialize(fragment)
    self.fragment = fragment
    self.activity = fragment.getActivity
  end
  
  def setData (objects)
    self.objects = objects
    notifyDataSetChanged()
  end
  
  def getItem(i)
    objects[i]
  end

  def getCount
    objects.length
  end

  def isViewFromObject(view, object)
    view == object
  end

  def destroyItem(container, position, object) 
    container.removeView object
  end

  def instantiateItem(container, position) 
    row = getItem(position)
    view = init_row row[:cell_type]
    Utils.insert_photo_for_circle_view(activity, {photo: row[:photo_url], image_view:  outlets['background']})
    container.addView(view);
    view
  end
end