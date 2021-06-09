module AdapterManager

  attr_accessor :fragment, :activity, :outlets, :objects

  def init_row(view_id)
    row = inflater.inflate(find_layout(view_id), nil)
    set_outlets row
    row
  end

  def inflater
    activity.getSystemService(Android::Content::Context::LAYOUT_INFLATER_SERVICE)
  end

  def set_outlets(view)
    self.outlets = OutletSet.new(package_name: activity.packageName, parent: activity, view: view)
  end

  def find(id)
    activity.resources.getIdentifier(id, 'id', activity.packageName)
  end
  
  def find_layout(layout_id)
    activity.resources.getIdentifier(layout_id, 'layout', activity.packageName)
  end
  
  def insert_photo(options = {})
    if (options[:photo] != "/images/original/missing.png")
      Com::Squareup::Picasso::Picasso.with(activity.getBaseContext()).load(options[:photo]).into(options[:image_view]).placeholder(R::Drawable::Profile_placeholder)
    end
  end
  
  def asset(asset_name)
    activity.resources.getIdentifier(asset_name, 'drawable', activity.packageName)
  end

  def get_color(color_id)
    activity.resources.getIdentifier(color_id, 'color', activity.packageName)
  end

  def get_string(string_id)
      activity.getString(activity.resources.getIdentifier(string_id, 'string', activity.packageName))
  end

end