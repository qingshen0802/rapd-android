class ContactDetailsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    self.outlets['contact_details_web_view'].loadUrl("http://www.trat.to/contact/")
  end

  def has_back_arrow?
    true    
  end

  def get_title
    get_string('contact_details_title')
  end

  def onClick(button)
    super(button)
  end

end