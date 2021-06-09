class NotificationRequestAcceptFragment < Android::Support::V4::App::Fragment

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
    @title_text_view = outlets['text_title']
    @subtitle_text_view = outlets['text_sub_title']
    @description_text_view = outlets['text_description']
    @profile_photo_view = outlets['profile_photo']
    @second_profile_photo = outlets['second_profile_photo']
    @btn_accept_request = outlets['btn_accept_payment']
    @btn_accept_request.setOnClickListener(self)

    @status_container = outlets['status_container']
    @status_container.set_gone

    @title_text_view.text = "#{self.notification.title}"
    @subtitle_text_view.text = "#{locale(self.notification.created_at)}"
    @description_text_view.text = "#{self.notification.description}"

    outlets['title_container'].setBackgroundColor(Android::Graphics::Color.parseColor("##{self.notification.color}"))
    Utils.insert_photo_for_circle_view(getActivity, {photo: self.notification.from_user_photo_url, image_view: @profile_photo_view})
    Utils.insert_photo_for_circle_view(getActivity, {photo: self.notification.from_user_photo_url, image_view: @second_profile_photo})

    load_transaction_request

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
        @btn_accept_request.set_gone
        @status_container.set_visible
        if self.transaction_reqeust.status == "canceled"
          self.outlets['text_status'].text = "This transaction request has been canceled."
        elsif self.transaction_reqeust.status == "processed"
          self.outlets['text_status'].text = "This transaction request is already processed."
        else
          self.outlets['text_status'].text = ""
        end
      else
        @btn_accept_request.set_visible
        @status_container.set_gone
      end
      @description_text_view.text = "#{@description_text_view.text} \n#{self.transaction_reqeust.request_description}"
    end
  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  def onClick(button)
    switch_to_fragment("accept_payment_request", container: 'main', fragment_attributes: {transaction_request: self.transaction_reqeust})
  end

  def locale(date)
    usa = Java::Text::SimpleDateFormat.new("yyyy-MM-dd", Java::Util::Locale::US)
    formattedDateUSA = usa.parse(date)
    dateFormat = Java::Text::SimpleDateFormat.new("dd/MM/yyyy", Java::Util::Locale::US)
    formattedDate = dateFormat.format(formattedDateUSA)
    formattedDate
  end
end