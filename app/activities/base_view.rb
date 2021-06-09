module BaseView
  
  def onClick(view)
    view.submit
  end
  
  def resource_creation_failed
  end

  def resource_update_failed
  end
  
  def current_user
    app_delegate.current_user
  end
  
  def app_delegate
    AppDelegate.shared_delegate
  end
  
end