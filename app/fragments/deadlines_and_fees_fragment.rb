class DeadlinesAndFeesFragment < Android::Support::V4::App::Fragment

  include FragmentManager

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def has_actionbar?
    true
  end

  def get_title
    get_string "deadlines_and_fees_title"
  end

  def has_back_arrow?
    true
  end

end