class SimpleOnPageChangeListener < Android::Support::V4::View::ViewPager::SimpleOnPageChangeListener
  
  def initialize (indicator)
    @indicator = indicator
  end
  
  def onPageScrollStateChanged(state) 
    @indicator.onPageScrollStateChanged(state)
  end

  def onPageScrolled(position, positionOffset, positionOffsetPixels)
    @indicator.onPageScrolled(position, positionOffset, positionOffsetPixels)
  end

  def onPageSelected(position) 
    @indicator.onPageSelected(position) 
  end
end