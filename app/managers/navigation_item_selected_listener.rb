class NavigationItemSelectedListener

  attr_accessor :activity

  def initialize(activity)
    @activity = activity
  end

  def onNavigationItemSelected(menuItem)
    activity.onNavigationItemSelected(menuItem)

    false
  end

end