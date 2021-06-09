class BankAccountFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
  end
  
  def get_title
    "Configurações Bancárias"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def onClick(button)
    super button
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end  
    true
  end
  
end
