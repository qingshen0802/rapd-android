class MainActivity < Android::Support::V7::App::AppCompatActivity
  
  include BaseView
  include BaseActivity
  include FragmentManager
  
  
  attr_accessor :toggle, :current_fragment
  
  def onCreate(savedInstanceState)
    super
    Net.context = self
    Store.context = self
    setContentView(find_layout('activity_main'))
    init_toolbar
    init_navigation_drawer
    switch_to_fragment("main", with_layout: 'activity_main', container: 'main')
  end
  
  def onCreateOptionsMenu(menu)
    getMenuInflater().inflate(get_menu("action_bar_main_menu"), menu);
    true
  end
  
  def onPostCreate(bundle)
    super 
  end
  
  def toolbar
    findViewById(R::Id::Toolbar)
  end
  
  def nav_widget
    findViewById(R::Id::Nav_view)
  end
  
  def nav_drawer
    findViewById(R::Id::Drawer_layout)
  end
  
  def create_back_button
    toggle.setDrawerIndicatorEnabled(false)
    getSupportActionBar().setDisplayHomeAsUpEnabled(true);
  end

  def show_hide_menu_item(menu_id, show)
    menu_item = toolbar.getMenu.findItem(find(menu_id))
    menu_item.setVisible show unless menu_item.nil? || menu_item.isVisible == show
  end
  
  def init_toolbar
    toolbar.setNavigationOnClickListener self
    getActivity.toolbar.getMenu().clear()
    setSupportActionBar(toolbar)
  end
  
  def set_toolbar_title (res_id)
    getSupportActionBar.setTitle(res_id)
  end
  
  def change_main_picture(url)
    photo = url.nil? || url == "/images/original/missing.png" ? get_drawable('profile_placeholder') : url
    Utils.insert_photo_for_circle_view(self,photo: photo, image_view: nav_widget.getHeaderView(0).findViewById(R::Id::Profile_image))
  end
  
  def change_secondary_picture(url)
    photo = url.nil? || url == "/images/original/missing.png" ? get_drawable('profile_placeholder') : url
    circle_view = nav_widget.getHeaderView(0).findViewById(R::Id::Profile_secondary_image)
    circle_view.set_visible
    Utils.insert_photo_for_circle_view(self,photo: photo, image_view: circle_view)
  end
  
  def change_username(username)
    nav_widget.getHeaderView(0).findViewById(R::Id::Username).text = username
  end

  def go_back
    getSupportFragmentManager().popBackStackImmediate()
    entry_count = getSupportFragmentManager().getBackStackEntryCount()
    if entry_count == 0
      self.current_fragment = nil
    else
      fragment_name = getSupportFragmentManager().getBackStackEntryAt(entry_count - 1).getName()
      self.current_fragment = getActivity.getSupportFragmentManager.findFragmentByTag(fragment_name)
    end
  end

  def go_back_to_fragment(back_destination)
    puts "Going back to destination"
    getSupportFragmentManager.popBackStack(back_destination, 0)
    self.current_fragment = getSupportFragmentManager.findFragmentByTag(back_destination)
  end
  
  def change_email(email)
    nav_widget.getHeaderView(0).findViewById(R::Id::Email).text = email
  end
  
  def set_toolbar_menu (res_id)
    toolbar.inflateMenu(res_id);
  end
  
  def init_navigation_drawer
    create_drawer_toggle
    nav_widget.setNavigationItemSelectedListener(self);
    nav_widget.getMenu().getItem(0).setChecked(true);
    nav_widget.getHeaderView(0).findViewById(R::Id::Profile_secondary_image_wrapper).addTarget(self,action: "change_profile")
    hide_notification_badge
    init_profile_information
    #show options dialog for click arrow button
    nav_widget.getHeaderView(0).findViewById(R::Id::Down_arrow).addTarget(self,action: "onArrowMenuClicked")
    @dialog = Android::App::Dialog.new(getActivity)
    @dialog.requestWindowFeature(Android::View::Window::FEATURE_NO_TITLE)
    @dialog.setContentView(R::Layout::Dialog_arrow_menu)
    @dialog.cancelable = true
    @dialog.findViewById(R::Id::Btn_logout).addTarget(self,action: "onLogout")
    @dialog.findViewById(R::Id::Btn_another_profile).addTarget(self,action: "onAccessAnotherProfile")
    @dialog.findViewById(R::Id::Btn_create_profile).addTarget(self,action: "onCreateProfile")
    @dialog.findViewById(R::Id::Btn_cancel).addTarget(self,action: "onCancelArrowDialog")
  end
  
  def change_profile
    if app_delegate.secondary_profile.nil?
      switch_to_fragment("store_sign_up", with_layout: 'activity_main', container: 'main') 
      close_nav_drawer
    else
      app_delegate.set_current_profile_id app_delegate.secondary_profile.remote_id
      init_profile_information
      nav_drawer.closeDrawer(Android::Support::V4::View::GravityCompat::START)
      nav_widget.getMenu().getItem(4).setChecked(true);
      #switch_to_fragment("profile", with_layout: 'activity_main', container: 'main')
      switch_to_fragment("main", with_layout: 'activity_main', container: 'main')
    end
  end
  
  def init_profile_information
    current_profile = app_delegate.current_profile
    business_profile = app_delegate.secondary_profile
    change_main_picture current_profile.photo_url
    if business_profile.nil?
      Utils.insert_photo_for_circle_view(self,photo: get_drawable('add'), image_view: nav_widget.getHeaderView(0).findViewById(R::Id::Add_profile))
    else
      nav_widget.getHeaderView(0).findViewById(R::Id::Add_profile).set_gone
      change_secondary_picture business_profile.photo_url
    end
    change_username current_profile.username
    change_email current_profile.email
  end
  
  def create_drawer_toggle
    getSupportActionBar().setDisplayHomeAsUpEnabled(false)
    self.toggle = Android::Support::V7::App::ActionBarDrawerToggle.new(
                  self, nav_drawer, toolbar, R::String::Navigation_drawer_open, R::String::Navigation_drawer_close);
    nav_drawer.setDrawerListener(toggle);
    toggle.setToolbarNavigationClickListener self
    toggle.syncState();
  end
  
  def change_notification_badge (num)
    nav_widget.getMenu().getItem(3).getActionView().findViewById(R::Id::Num).setText("#{num}")
  end
  
  def hide_notification_badge
    nav_widget.getMenu().getItem(3).getActionView().set_gone
  end
  
  def getActivity
    self
  end
  
  def onClick (view)
    if view.getId == -1
      back_arrow_or_button_pressed
    else
      super
    end
  end

  def onBackPressed
    if getSupportFragmentManager().getBackStackEntryCount() > 1
      back_arrow_or_button_pressed
    else
      finish
    end
  end

  def back_arrow_or_button_pressed
    if !current_fragment.nil? && current_fragment.respond_to?(:on_toolbar_back_pressed)
      if !current_fragment.on_toolbar_back_pressed
        go_back
      end
    else
      go_back
    end
  end
  
  def onNavigationItemSelected (item) 
    map = {:"#{R::Id::Nav_home}" => "main",:"#{R::Id::Nav_partners}" => "partner",:"#{R::Id::Nav_payments}" => "pay_or_request",
           :"#{R::Id::Nav_notifications}" => "notification",:"#{R::Id::Nav_profile}" => "profile"}
    switch_to_fragment(map[:"#{item.getItemId}"], with_layout: 'activity_main', container: 'main')
    close_nav_drawer
    true
  end
  
  def close_nav_drawer
    nav_drawer.closeDrawer(Android::Support::V4::View::GravityCompat::START)
  end
  
  def onOptionsItemSelected(item)
    count = self.getSupportFragmentManager().getBackStackEntryCount()
    fragment = self.getSupportFragmentManager().getFragments.get(count > 0 ? count-1:count)
    fragment.send("action_bar_#{item.getTitle}") if fragment.respond_to?("action_bar_#{item.getTitle}")
    true
  end

  __annotation__("@android.webkit.JavascriptInterface")
  def permission_returned (requestCode,permissions,grantResults)
    count = self.getSupportFragmentManager().getBackStackEntryCount()
    fragment = self.getSupportFragmentManager().getFragments.get(count > 0 ? count-1:count)
    fragment.load_contacts
    return
    case (requestCode) 
    when  42
        if (grantResults.size > 0 && grantResults[0] == Android::Content::Pm::PackageManager::PERMISSION_GRANTED) 
          fragment.load_contacts
        else 
          return
        end
    end
  end
  
  def onArrowMenuClicked
    if !@dialog.isShowing
      @dialog.show
    else
      @dialog.dismiss
    end  
  end

  def onLogout
    login_manager = LoginManager.shared_manager
    login_manager.delegate = self
    login_manager.logout
    @dialog.dismiss
    #present_activity("welcome")
    switch_to_fragment("sign_in", container: 'main')
    close_nav_drawer  
  end

  def onAccessAnotherProfile
    @dialog.dismiss
    change_profile
  end

  def onCreateProfile
    @dialog.dismiss
    switch_to_fragment("store_sign_up", with_layout: 'activity_main', container: 'main') 
      close_nav_drawer
  end

  def onCancelArrowDialog
    @dialog.dismiss
  end

end
