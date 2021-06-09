class WelcomeActivity < Android::Support::V7::App::AppCompatActivity
  
  include BaseView
  include BaseActivity
  include FragmentManager
  
  def onCreate(savedInstanceState)
    # --> This is an issue that only appears when using the Starter version of RubyMotion. Simply remove the "super" call in your "onCreate" method.
    super
    Net.context = self
    Store.context = self
    setContentView(find_layout('activity_welcome'))
    init_toolbar
    if app_delegate.logged_in?
      present_main
    else
      switch_to_fragment('welcome', with_layout: 'activity_welcome', container: 'welcome')
    end
    setRequestedOrientation(Android::Content::Pm::ActivityInfo::SCREEN_ORIENTATION_PORTRAIT)
  end
  
  def toolbar
    findViewById(R::Id::Toolbar)
  end
  
  def create_back_button
    getSupportActionBar().setDisplayHomeAsUpEnabled(true)
  end
  
  def init_toolbar
    toolbar.setNavigationOnClickListener self
    toolbar.getMenu().clear()
    setSupportActionBar(toolbar)
  end
  
  def set_toolbar_title (res_id)
    getSupportActionBar.setTitle(res_id)
  end
  
  def set_toolbar_menu (res_id)
    toolbar.inflateMenu(res_id)
  end
  
  def onClick (view)
    getSupportFragmentManager().popBackStack()
  end
  
  def getActivity
    self
  end
  
end