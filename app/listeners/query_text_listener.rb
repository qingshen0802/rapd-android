class QueryTextListener < Android::Widget::SearchView
  attr_accessor :target, :action
  def initialize(target, action)
    self.target = target
    self.action = action
  end
  
  def onQueryTextChange(newText)
    false
  end
    
  def onQueryTextSubmit(query)
    false
  end
end