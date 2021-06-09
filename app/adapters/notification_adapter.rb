class NotificationAdapter < Android::Widget::BaseAdapter
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
    if row[:cell_type] == "divider"
      view =	Android::Widget::TextView.new(activity.getApplicationContext())
      view.text =  row[:title]
      view.textColor = Android::Graphics::Color::GRAY
      view.setPadding(30, 60, 0, 30);
    else
      view = init_row row[:cell_type]
      outlets['title'].text = row[:title]
      outlets['sub_title'].text = row[:subtitle]
      notification = row[:notification]

      dotView = outlets['dot_view']
      dotView.setBackgroundColor(Android::Graphics::Color.parseColor("##{notification.color}"))

      if notification.type.include? "PaymentRequestNotification"
        if notification.title.include? "Solicitação de pagamento enviada"
          insert_photo(image_view: outlets['item_photo'], photo: notification.to_user_photo_url)
        else
          insert_photo(image_view: outlets['item_photo'], photo: notification.from_user_photo_url)
        end
      elsif notification.type.include? "MentionNotification"
        insert_photo(image_view: outlets['item_photo'], photo: notification.from_user_photo_url)
      elsif notification.type.include? "MessageNotification"
        insert_photo(image_view: outlets['item_photo'], photo: notification.from_user_photo_url)
      elsif notification.type.include? "PromotionNotification"
        insert_photo(image_view: outlets['item_photo'], photo: notification.from_user_photo_url)
      elsif notification.type.include? "PaymentNotification"
        insert_photo(image_view: outlets['item_photo'], photo: notification.to_user_photo_url)
      elsif notification.type.include? "ReceiptNotification"
        insert_photo(image_view: outlets['item_photo'], photo: notification.from_user_photo_url)
      end
    end
    view
  end
end