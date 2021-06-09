class TermsOfUseFragment < Android::Support::V4::App::Fragment
  
  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('terms_of_use_title')
  end
  
  def load_views
    self.outlets['terms_web_view'].loadData(get_string('Text_terms_of_use'), 'text/html', 'UTF-8')
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
end