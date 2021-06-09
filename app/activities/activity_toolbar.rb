module ActivityToolbar
  
  def toolbar
    findViewById(R::Id::Toolbar)
  end
  
  def init_toolbar
    toolbar.setNavigationOnClickListener self
    getActivity.toolbar.getMenu().clear()
    setSupportActionBar(toolbar)
  end
  
  def create_back_button
    getSupportActionBar().setDisplayHomeAsUpEnabled(true)
    getSupportActionBar().show
  end
  
  def set_toolbar_title (res_id)
    getSupportActionBar.setTitle(res_id)
  end
  
  def set_toolbar_menu (res_id)
    toolbar.inflateMenu(res_id);
  end  
end