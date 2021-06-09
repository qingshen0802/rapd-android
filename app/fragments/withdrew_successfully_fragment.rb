class WithdrewSuccessfullyFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :human_amount

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "withdrew_successfully_title"
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def onClick(view)
    super view
  end

  def on_toolbar_back_pressed
    switch_to_fragment("profile", container: "main")
    true
  end

  def load_views
    outlets["value_requested"].text = get_string("withdraw_success_message") % human_amount
    outlets["ok"].addTarget(self, action: "back_to_profile")
  end

  def back_to_profile
    switch_to_fragment("profile", container: "main")
  end

end