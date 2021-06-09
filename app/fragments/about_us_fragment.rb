class AboutUsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def load_views
    self.outlets['about_us_web_view'].loadUrl("http://www.trat.to/about/")
  end

  def has_back_arrow?
    true
  end

  def get_title
    "Sobre Nós"
  end

  def onClick(button)
    super(button)
  end
end