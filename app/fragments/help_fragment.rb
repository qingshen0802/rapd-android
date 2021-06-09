class HelpFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('help_title')
  end
  
  def load_views
    self.outlets['help_web_view'].loadUrl("http://www.trat.to/faq/")
  end

  def has_back_arrow?
    true    
  end  

  def onClick(button)
    super(button)
  end

end