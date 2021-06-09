class PayOrRequestFinishedDialogFragment < Android::Support::V4::App::DialogFragment
  
  include BaseView
  include FragmentManager

  attr_accessor :main_fragment, :sucessful, :message, :on_click_new, 
  :on_click_finish, :should_display_credits, :credits, :credits_earned,
  :is_open_billing, :is_dormant_billing, :billing


  def self.newInstance(main_fragment, sucessful, message, on_click_new, 
              on_click_finish, should_display_credits,
              is_open_billing, is_dormant_billing, billing)
    dialog = PayOrRequestFinishedDialogFragment.new
    dialog.main_fragment = main_fragment
    dialog.sucessful = sucessful
    dialog.message = message
    dialog.on_click_new = on_click_new
    dialog.on_click_finish = on_click_finish
    dialog.should_display_credits = should_display_credits
    # dialog.credits = credits
    # dialog.credits_earned = credits_earned
    dialog.is_open_billing = is_open_billing
    dialog.is_dormant_billing = is_dormant_billing
    dialog.billing = billing
    dialog
  end

  def onClick(view)
    super view
  end

  def get_title
    get_string "pay_or_request_finished_dialog_title"
  end

  def has_actionbar?
    false
  end

  def nested_fragment?
    true
  end

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def onStart
    super
    dialog = getDialog
    window = dialog.getWindow

    dialog.setCancelable(false)
    window.setGravity(Android::View::Gravity::CENTER_HORIZONTAL | Android::View::Gravity::BOTTOM)
    window.setBackgroundDrawable(Android::Graphics::Drawable::ColorDrawable.new(Android::Graphics::Color::TRANSPARENT))
    params = window.getAttributes
    params.width = Android::View::ViewGroup::LayoutParams::MATCH_PARENT
    params.horizontalMargin = 0;
    params.verticalMargin = 0;
    window.setAttributes params
    window.clearFlags(Android::View::WindowManager::LayoutParams::FLAG_DIM_BEHIND);
  end

  def load_views
    getActivity.create_back_button
    outlets["pay_or_request_dialog_new_request"].addTarget(self, action: "make_another")
    outlets["pay_or_request_dialog_finish"].addTarget(self, action: "finish")

    outlets["pay_or_request_dialog_text"].text = message
    if is_open_billing
      getActivity.set_toolbar_title(get_string("request_sent"))
      outlets["view"].set_gone
      outlets["share_link_container"].set_visible
      outlets["share_link_text"].text = billing[:open_billing_link]
      outlets["pay_or_request_dialog_twitter"].set_invisible
      outlets["pay_or_request_dialog_fb"].set_invisible
    # elsif is_dormant_billing
    #   outlets["pay_or_request_dialog_text"].setTextSize 14
    # elsif should_display_credits && credits > 0
    #   outlets["establishment_info_container"].set_visible
    #   outlets["establishment_message"].text = get_string("no_credits_used") % [Utils.format_money_br(credits_earned), Utils.format_money_br(credits + credits_earned)]
    end
  end

  def onCreateDialog(savedInstanceState)
    dialog = super
    dialog.getContext.setTheme(R::Style::BottomToUpTheme)
    dialog.getWindow.requestFeature(Android::View::Window::FEATURE_NO_TITLE)
    dialog
  end

  def make_another
    main_fragment.send(on_click_new)
  end

  def finish
    main_fragment.send(on_click_finish)
  end

end
