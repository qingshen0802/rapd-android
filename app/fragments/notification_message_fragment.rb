class NotificationMessageFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :notification

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    "MessageNotification"
  end

  def load_views
    puts "#{self.notification.to_json}"
    @title_text_view = outlets['text_title']
    @subtitle_text_view = outlets['text_sub_title']
    @profile_photo_view = outlets['profile_photo']

    @title_text_view.text = "#{self.notification.title}"
    @subtitle_text_view.text = "#{locale(self.notification.created_at)}"

    outlets['title_container'].setBackgroundColor(Android::Graphics::Color.parseColor("##{self.notification.color}"))
    if self.notification.to_user_photo_url != nil
      Utils.insert_photo_for_circle_view(getActivity, {photo: self.notification.to_user_photo_url, image_view: @profile_photo_view})
    end
  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  def onClick(button)
    super(button)
  end

  def locale(date)
    usa = Java::Text::SimpleDateFormat.new("yyyy-MM-dd", Java::Util::Locale::US)
    formattedDateUSA = usa.parse(date)
    dateFormat = Java::Text::SimpleDateFormat.new("dd/MM/yyyy", Java::Util::Locale::US)
    formattedDate = dateFormat.format(formattedDateUSA)
    formattedDate
  end
end