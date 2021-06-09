class WithdrawFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :wallets, :wallet, :amount, :api_level_ok, 
                :last_input_value, :last_cursor_position

  def onCreate(savedInstanceState)
    super
    
  end

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def get_title
    get_string "withdraw_title"
  end

  def onClick(view)
    super view
  end

  def load_views
    self.api_level_ok = Android::Os::Build::VERSION::SDK_INT >= 16
    self.wallet = app_delegate.default_wallet
    self.amount = 0
    set_currency_text
    set_amount_text 0 if api_level_ok
    set_percentage_text 0
    outlets["amount"].addTextChangedListener(TextChangedListener.new(self, "amount_text_changed"))
    set_slider
    outlets["change_wallet"].addTarget(self, action: "change_wallet")
    outlets["withdraw_button"].addTarget(self, action: "withdraw")
  end


  def set_slider
    if api_level_ok
      outlets["donut_progress"].set_gone
      outlets["circular_slider"].set_visible
      outlets["circular_slider"].setOnSliderRangeMovedListener(OnSliderRangeMovedListener.new(self, "slider_moved"))
    else
      outlets["donut_progress"].set_visible
      outlets["circular_slider"].set_gone
      outlets["amount"].requestFocus
    end
  end

  def slider_moved(pos)
    self.amount = (wallet.balance / 100.0) * (pos / 3.6).ceil
    if amount <= 0
      set_slider_position 0
    end
    set_amount_text amount
    set_percentage_text amount
    self.last_input_value = get_amount_from_input
    outlets["container"].requestFocus
  end

  def amount_text_changed
    unless @non_user_change
      self.amount = get_amount_from_input
      if amount > wallet.balance
        self.amount = self.last_input_value || 0
        self.last_cursor_position = outlets["amount"].getSelectionStart - 1
        set_amount_text amount
        outlets["amount"].setSelection(self.last_cursor_position)
      end
      self.last_input_value = get_amount_from_input
      set_percentage_text amount
      set_slider_position amount
    end
    @non_user_change = false
  end

  def get_amount_from_input
    outlets["amount"].text_as_string.gsub(",",".").to_f
  end

  def change_wallet
    ChooseWalletFragment.new_instance(self, self.wallets).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def withdraw
    if !self.amount.nil? && self.amount > 0
      switch_to_fragment("select_payment_type", container: "main", add: true, fragment_attributes: withdraw_params )
    else
      Utils.show_dialog(getActivity, "Error", "Amount is zero.")
    end
  end

  def withdraw_params
    {
      amount: self.amount.round(2),
      currency_id: self.wallet.wallet_type.currency_id,
      wallet_id: self.wallet.id
    }
  end

  def wallet_changed(i)
    self.wallet = wallets[i]
    set_currency_text
    self.last_input_value = nil
    self.last_cursor_position = nil
    if api_level_ok
      set_amount_text 0
    else
      set_amount_text_empty
    end
    set_percentage_text 0
    set_slider_position 0
  end

  def set_amount_text(amount)
    @non_user_change = true
    outlets["amount"].text = Utils.format_money(amount).gsub("-","")
  end

  def set_amount_text_empty
    @non_user_change = true
    outlets["amount"].text = ""
  end

  def set_percentage_text(amount)
    percent = wallet.balance > 0 ? (amount / wallet.balance * 100) : 0
    outlets["percent"].text = "#{percent.floor}%"
  end

  def set_slider_position(amount)
    percent = wallet.balance > 0 ? (amount / wallet.balance * 100) : 0
    angle =  percent * 3.6
    angle = angle - 0.0001 if angle >= 360
    if amount > 0 && percent.floor == 0
      angle = angle + 0.0001
      percent = 1
    end
    if api_level_ok
      outlets["circular_slider"].setEndAngle angle
      outlets["circular_slider"].invalidate
    else
      outlets["donut_progress"].setProgress(percent.floor)
    end
  end

  def set_currency_text
    text = "#{wallet.wallet_type.currency.short_name} - #{wallet.wallet_type.currency.name}"
    outlets["currency_name"].text = text
  end

end
