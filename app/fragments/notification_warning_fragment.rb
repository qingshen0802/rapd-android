class NotificationWarningFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :notification

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    "WarningNotification"
  end

  def load_views
    # puts "#{self.notification.to_json}"
    @title_text_view = outlets['text_title']
    @subtitle_text_view = outlets['text_sub_title']
    @description_text_view = outlets['text_description']
    @profile_photo_view = outlets['profile_photo']
    @profile_sub_photo = outlets['profile_photo_sub']

    @title_text_view.text = "#{self.notification.title}"
    @subtitle_text_view.text = "#{locale(self.notification.created_at)}"
    @description_text_view.text = "#{self.notification.description}"

    outlets['title_container'].setBackgroundColor(Android::Graphics::Color.parseColor("##{self.notification.color}"))
    if app_delegate.current_profile.photo_url != nil
      Utils.insert_photo_for_circle_view(getActivity, {photo: app_delegate.current_profile.photo_url, image_view: @profile_photo_view})
      Utils.insert_photo_for_circle_view(getActivity, {photo: app_delegate.current_profile.photo_url, image_view: @profile_sub_photo})
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