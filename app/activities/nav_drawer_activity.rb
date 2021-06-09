class NavDrawerActivity < Android::Support::V7::App::AppCompatActivity
  
  include BaseView
  include BaseActivity
  include FragmentManager
  
  attr_accessor :nav_widget, :nav_drawer, :toolbar, :toggle
  
  def onCreate(savedInstanceState)
    super
    Net.context = self
    Store.context = self
    setContentView(find_layout('activity_nav_drawer'))
    init_toolbar
    init_navigation_drawer
    change_notification_badge 12
    change_main_picture ""
  end
  
  def onPostCreate(savedInstanceState)
    super
    toggle.syncState();
  end
  
  def create_back_button
    toggle.setDrawerIndicatorEnabled(false);
    getSupportActionBar().setDisplayHomeAsUpEnabled(true);
  end
  
  def onConfigurationChange(newConfig)
    super
    toggle.onConfigurationChanged(newConfig);
  end
  
  def init_toolbar
    self.toolbar = find("toolbar")
    setSupportActionBar(toolbar)
  end
  
  def set_toolbar_title (res_id)
    getSupportActionBar.setTitle(res_id)
  end
  
  def set_toolbar_menu (res_id)
    toolbar.getMenu().clear()
    toolbar.inflateMenu(res_id);
  end
  
  def init_navigation_drawer
    self.nav_widget = find("nav_view")
    self.nav_drawer =  find("drawer_layout")
    create_drawer_toggle
    nav_widget.setNavigationItemSelectedListener(self);
  end
  
  def create_drawer_toggle
    self.toggle = Android::Support::V7::App::ActionBarDrawerToggle.new(
                  self, nav_drawer, toolbar, R::String::Navigation_drawer_open, R::String::Navigation_drawer_close);
    nav_drawer.setDrawerListener(toggle);
    toggle.syncState();
  end
  
  def change_notification_badge (num)
    nav_widget.getMenu().getItem(3).getActionView().set_gone
  end
  
  def change_main_picture(url)
    insert_photo_for_circle_view(self,photo: "http://weknowyourdreams.com/image.php?pic=/images/people/people-06.jpg", image_view: nav_widget.getHeaderView(0).findViewById(R::Id::Profile_image) )
  end
  
  def getActivity
    self
  end
  
  def onNavigationItemSelected (item) 
    map = {:"#{R::Id::Nav_home}" => "main",:"#{R::Id::Nav_partners}" => "partner",:"#{R::Id::Nav_payments}" => "pay_or_request",
           :"#{R::Id::Nav_notifications}" => "notifications",:"#{R::Id::Nav_profile}" => "profile"}
    switch_to_fragment(map[:"#{item.getItemId}"], with_layout: 'activity_nav_drawer', container: 'frag')
    nav_drawer.closeDrawer(Android::Support::V4::View::GravityCompat::START)
    true
  end
  
  def onOptionsItemSelected(item) 
    count = self.getSupportFragmentManager().getBackStackEntryCount()
    fragment = self.getSupportFragmentManager().getFragments.get(count > 0 ? count-1:count)
    if item.getItemId() == R::Id::Home
      getSupportFragmentManager().popBackStack()
    else
      fragment.send("action_bar_#{item.getTitle}") if fragment.respond_to?("action_bar_#{item.getTitle}")
    end
    true
  end
end