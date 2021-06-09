class ContactListFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    adapter = ContactListViewPagerAdapter.new(getActivity.getSupportFragmentManager)
    outlets['pager'].adapter = adapter
    outlets['tabs'].setupWithViewPager(outlets['pager']);
  end
  
  def load_contacts
    getActivity.getSupportFragmentManager().findFragmentByTag("android:switcher:#{R::Id::Pager}:1").load_contacts
  end
  
  def get_title
    "Contatos"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def has_actionbar_menu?
    true
  end
  
  
  def onClick(button)
    super button
  end
end