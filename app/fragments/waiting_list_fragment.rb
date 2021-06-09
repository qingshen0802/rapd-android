class WaitingListFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('wait_list')
  end
  
  def load_views
    self.outlets['share_button'].addTarget(self, action: 'share')
  end

  def share
    getActivity.present_main
  end

  def onClick(button)
    super(button)
  end
end