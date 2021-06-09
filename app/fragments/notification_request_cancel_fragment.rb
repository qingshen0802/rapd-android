class NotificationRequestCancelFragment< Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :notification, :transaction_reqeust

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    "PaymentRequestNotification"
  end

  def load_views
    puts "#{self.notification.to_json}"
    @title_text_view = outlets['text_title']
    @subtitle_text_view = outlets['text_sub_title']
    @description_text_view = outlets['text_description']
    @profile_photo_view = outlets['profile_photo']
    @second_profile_photo = outlets['second_profile_photo']

    @btn_cancel_request = outlets['btn_cancel_payment']
    @btn_cancel_request.setOnClickListener(self)
    @btn_cancel_request.set_gone

    @status_container = outlets['status_container']
    @status_container.set_gone

    @title_text_view.text = "#{self.notification.title}"
    @subtitle_text_view.text = "#{locale(self.notification.created_at)}"
    @description_text_view.text = "#{self.notification.description}"

    outlets['title_container'].setBackgroundColor(Android::Graphics::Color.parseColor("##{self.notification.color}"))
    Utils.insert_photo_for_circle_view(getActivity, {photo: self.notification.to_user_photo_url, image_view: @profile_photo_view})
    Utils.insert_photo_for_circle_view(getActivity, {photo: self.notification.from_user_photo_url, image_view: @second_profile_photo})

    load_transaction_request

  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  def onClick(button)
    cancel_request
  end

  def locale(date)
    usa = Java::Text::SimpleDateFormat.new("yyyy-MM-dd", Java::Util::Locale::US)
    formattedDateUSA = usa.parse(date)
    dateFormat = Java::Text::SimpleDateFormat.new("dd/MM/yyyy", Java::Util::Locale::US)
    formattedDate = dateFormat.format(formattedDateUSA)
    formattedDate
  end

  def load_transaction_request
    request_manager = TransactionRequestManager.shared_manager
    request_manager.delegate = self
    request_manager.fetch(self.notification.notifiable_id)
  end

  def item_fetched(element)
    if element.is_a?(TransactionRequest)
      self.transaction_reqeust = element
      if self.transaction_reqeust.status == "canceled" || self.transaction_reqeust.status == "processed"
        @btn_cancel_request.set_gone
        @status_container.set_visible
        if self.transaction_reqeust.status == "canceled"
          self.outlets['text_status'].text = "This transaction request has been canceled."
        elsif self.transaction_reqeust.status == "processed"
          self.outlets['text_status'].text = "This transaction request is already processed."
        else
          self.outlets['text_status'].text = ""
        end
      else
        @btn_cancel_request.set_visible
        @status_container.set_gone
      end
      @description_text_view.text = "#{@description_text_view.text} \n#{self.transaction_reqeust.request_description}"
    end
  end

  def cancel_request
    cancel_payment
  end

  def cancel_payment
    update_transaction_reqeust
  end

  def update_transaction_reqeust
    @dialog = Utils.loading_dialog getActivity
    self.transaction_reqeust.status = "canceled"
    self.transaction_reqeust.to_profile_id = self.transaction_reqeust.from_profile_id
    self.transaction_reqeust.from_profile_id = app_delegate.current_profile_id
    request_udpate_manager = TransactionRequestManager.shared_manager
    request_udpate_manager.delegate = self
    request_udpate_manager.update_resource(self.transaction_reqeust)
  end
  def resource_updated(element)
    @dialog.dismiss
    remove_notification(self.notification)
  end

  def resource_update_failed
    p "Error occured"
  end

  def remove_notification(del_notification)
    noti_manager = NotificationManager.shared_manager
    noti_manager.delegate = self
    noti_manager.delete_resource(del_notification)
  end

  def resource_deleted
    go_back
  end

end