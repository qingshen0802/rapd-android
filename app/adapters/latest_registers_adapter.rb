class LatestRegistersAdapter < Android::Widget::BaseAdapter
  include AdapterManager

  attr_accessor :list_type, :wallet

  def initialize(activity, objects, list_type, wallet)
    self.activity = activity
    self.objects = objects
    self.list_type = list_type
    self.wallet = wallet
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
      view = init_row 'custom_row_latest_registers'
      object =  getItem(i)
      if self.list_type == 0
        if object.amount >= 0
          outlets['title'].text = "@#{object.from_profile['username']}"
          insert_photo(image_view: outlets['image_list'], photo: object.from_profile['photo_url'])
          outlets['value_credited'].setTextColor(Android::Graphics::Color::GRAY)
          outlets['value_credited'].text = "#{self.wallet.wallet_type.currency.short_name}#{object.amount.to_s}"
        else
          outlets['title'].text = "@#{object.to_profile['username']}"
          insert_photo(image_view: outlets['image_list'], photo: object.to_profile['photo_url'])
          outlets['value_credited'].setTextColor(Android::Graphics::Color.parseColor("#F15E4F"))
          outlets['value_credited'].text = "-#{self.wallet.wallet_type.currency.short_name}#{object.amount.abs.to_s}"
        end
        outlets['time_ago'].text = object.created_at.to_s
      elsif self.list_type == 1
        outlets['title'].text = "@#{object.to_profile['username']}"
        insert_photo(image_view: outlets['image_list'], photo: object.to_profile['photo_url'])
        outlets['time_ago'].text = object.created_at.to_s
        outlets['value_credited'].setTextColor(Android::Graphics::Color.parseColor("#F15E4F"))
        outlets['value_credited'].text = "-#{self.wallet.wallet_type.currency.short_name}#{object.amount.abs.to_s}"
      else
        outlets['title'].text = "@#{object.from_profile['username']}"
        insert_photo(image_view: outlets['image_list'], photo: object.from_profile['photo_url'])
        outlets['time_ago'].text = object.created_at.to_s
        outlets['value_credited'].setTextColor(Android::Graphics::Color::GRAY)
        outlets['value_credited'].text = "#{self.wallet.wallet_type.currency.short_name}#{object.amount.to_s}"
      end
    view
  end
end