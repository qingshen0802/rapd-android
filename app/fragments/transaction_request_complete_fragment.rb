class TransactionRequestCompleteFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :success

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string(success ? "success" : "error")
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
    if !back_destination.nil?
      go_back_to_fragment back_destination
      true
    else
      false
    end
  end

  def load_views
    outlets["image"].setImageResource(get_drawable(success ? "check" : "close_white_icon"))
    outlets["message"].text = get_string(success ? "transaction_success_message" : "transaction_failure_message")
  end

end
