class PayOrRequestFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :is_open_billing, :is_dormant_billing,
                :establishment, :wallet, :selected_profiles,
                :action_bar_check_mark, :action_bar_connect_device, 
                :current_layout, :discount_id, :discount_amount, :successful,
                :profiles, :establishments, :wallets, :rapd_transaction, :transaction_type, :amount_field, :payment_amount

  LAYOUT_ESTABLISHMENT = 0
  LAYOUT_PROFILES = 1
  LAYOUT_PAY_OR_REQUEST = 2
  LAYOUT_PAY_ESTABLISHMENTS = 3


  def onCreateView(inflater, container, savedInstanceState)
    super
    self.selected_profiles ||= []
    # @nfc = true
    Utils.disable_resize_on_keyboard_open getActivity
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end


  def has_actionbar?
    true
  end

  def has_actionbar_menu?
    true
  end

  def onClick(button)
    super button
  end

  def onItemSelected(parent, view, pos, id)
    super
  end

  def get_title
    get_string 'pay_or_request_title'
  end

  def on_toolbar_back_pressed
    if current_layout == LAYOUT_ESTABLISHMENT
      return false
    elsif current_layout == LAYOUT_PAY_ESTABLISHMENTS
      change_layout LAYOUT_ESTABLISHMENT
    elsif current_layout == LAYOUT_PAY_OR_REQUEST
      self.is_open_billing = false
      change_layout LAYOUT_ESTABLISHMENT
    end

    true
  end

  def action_bar_pay_request_profiles
    set_profile_search_text
    profiles = outlets["pay_or_request_users_name"].text_as_string
    set_search_text profiles.chomp(", ")
    self.is_open_billing = false
    getActivity.show_hide_menu_item('action_check', false)
    change_layout LAYOUT_PAY_OR_REQUEST
  end

  # def action_bar_connect_device
    # dialog = ConnectDeviceFragment.new_instance(@nfc)
    # dialog.show(getActivity().getSupportFragmentManager(), "connect_device_dialog")
    # @nfc = !@nfc
  # end

  def action_bar_load_funds
    switch_to_fragment('load_money', container: 'main', fragment_attributes: {back_destination: 'pay_or_request'})
  end

  def load_views
    load_nearby_establishments
    load_wallets
    @profile_adapter = ProfileSearchAdapter.new(self, [])
    @text_listener = TextChangedListener.new(self, "search_text_changed")
    outlets["send_payment_button"].addTarget(self, action: "send_payment")
    outlets["request_payment_button"].addTarget(self, action: "request_payment")
    # outlets["pay_or_request_request_button"].addTarget(self, action: "create_open_billing")
    outlets["show_change_wallet"].addTarget(self, action: "show_choose_wallet_dialog")
    outlets["pay_or_request_img_clear"].addTarget(self, action: "clear_profile_search")
    outlets["pay_or_request_users_name"].addTextChangedListener(@text_listener)
    self.amount_field = outlets["pay_or_request_value"]
    self.amount_field.addTextChangedListener(NumberTextWatcher.new(self, self.amount_field, nil))
    self.amount_field.setOnFocusChangeListener(FocusChangeListener.new(self, "set_payment_value_factor"))
    change_layout LAYOUT_ESTABLISHMENT

    self.wallet = app_delegate.default_wallet
  end

  def change_layout(layout)
    self.current_layout = layout
    reset_layout
    case layout
      when LAYOUT_ESTABLISHMENT
        set_layout_establishment
      when LAYOUT_PROFILES
        set_layout_profiles
      when LAYOUT_PAY_OR_REQUEST
        set_layout_pay_or_request_profile
      when LAYOUT_PAY_ESTABLISHMENTS
        set_layout_pay_establishments
    end
  end

  def set_send_payment_state
    if !self.wallet.nil? && self.wallet.balance <= 0
      disable_payment
    else
      enable_payment
    end
  end

  def disable_payment
    outlets["send_payment_button"].setPaintFlags(outlets["send_payment_button"].getPaintFlags() | Android::Graphics::Paint::STRIKE_THRU_TEXT_FLAG)
    getActivity.show_hide_menu_item('action_load_funds', true)
  end

  def enable_payment
    outlets["send_payment_button"].setPaintFlags(outlets["send_payment_button"].getPaintFlags() & ~Android::Graphics::Paint::STRIKE_THRU_TEXT_FLAG)
    getActivity.show_hide_menu_item('action_load_funds', false)
  end

  def reset_layout
    reset_values
    enable_payment
    @is_establishment = false
    getActivity.set_toolbar_title get_title
    getActivity.create_drawer_toggle
    outlets["pay_or_request_label1"].set_visible
    outlets["pay_or_request_users_name"].set_visible
    outlets["pay_or_request_separator"].set_visible
    outlets["pay_or_request_list_view"].set_visible
    # outlets["pay_or_request_request_button"].set_gone
    outlets["pay_or_request_label2"].set_gone
    outlets["pay_or_request_form_container"].set_gone
    outlets["pay_or_request_buttons"].set_gone
    outlets["send_payment_button"].set_visible
    outlets["request_payment_button"].set_visible
    outlets["establishments_info_container"].set_gone
    outlets["value_bottom_border"].set_visible
    outlets["comment_bottom_border"].set_visible
    outlets["no_account_alert_container"].set_gone
    # getActivity.show_hide_menu_item('action_connect', false)
    getActivity.show_hide_menu_item('action_check', false)
    getActivity.show_hide_menu_item('action_load_funds', false)
  end

  def reset_values
    self.amount_field.text = ""
    outlets["pay_or_request_comments"].text = ""
    if self.current_layout == LAYOUT_ESTABLISHMENT && outlets["pay_or_request_users_name"].text_as_string.length > 0
      set_search_text ""
    end
    self.discount_id = 0
    self.discount_amount = 0
    unless self.current_layout == LAYOUT_PROFILES || self.current_layout == LAYOUT_PAY_OR_REQUEST
      self.selected_profiles = []
    end
    unless self.current_layout == LAYOUT_ESTABLISHMENT || self.current_layout == LAYOUT_PAY_ESTABLISHMENTS
      self.establishment = nil
    end
  end

  def set_layout_establishment
    # getActivity.show_hide_menu_item('action_connect', true)
    outlets["pay_or_request_label2"].set_visible
    # outlets["pay_or_request_request_button"].set_visible
    outlets["pay_or_request_list_view"].adapter = @establishment_adapter
  end

  def set_layout_profiles
    getActivity.show_hide_menu_item('action_check', self.selected_profiles.length > 0 ? true : false)
    outlets["pay_or_request_list_view"].adapter = @profile_adapter
  end

  def set_layout_pay_or_request_profile
    set_send_payment_state
    outlets["pay_or_request_buttons"].set_visible
    outlets["pay_or_request_list_view"].set_gone
    outlets["pay_or_request_form_container"].set_visible
    self.amount_field.requestFocus
    if is_open_billing
      getActivity.set_toolbar_title get_string("request_payment")
      getActivity.create_back_button
      outlets["send_payment_button"].set_gone
      outlets["pay_or_request_label1"].set_gone
      outlets["pay_or_request_users_name"].set_gone
      outlets["pay_or_request_separator"].set_gone
    elsif is_dormant_billing
      outlets["no_account_alert_container"].set_visible
      outlets["pay_or_request_alert_clear"].addTarget(self, action: "dismiss_no_account_message")
    end
  end

  def set_layout_pay_establishments
    set_send_payment_state
    getActivity.set_toolbar_title get_string("pay_to_store")
    getActivity.create_back_button
    @is_establishment = true
    outlets["pay_or_request_img_clear"].set_gone
    outlets["establishments_info_container"].set_gone
    outlets["pay_or_request_buttons"].set_visible
    outlets["request_payment_button"].set_visible
    outlets["pay_or_request_label1"].set_visible
    outlets["pay_or_request_users_name"].set_visible
    outlets["pay_or_request_separator"].set_visible
    outlets["pay_or_request_form_container"].set_visible
    full_name = self.establishment.full_name
    outlets["pay_or_request_users_name"].text = full_name
    self.amount_field.requestFocus
    # if !self.establishment.nil? && self.establishment.credits_amount > 0
    #   credits_message = get_string("you_got_credits_on_establishment") % ["#{Utils.format_money_br(self.establishment.credits_amount)}", self.establishment[:name]]
    #   outlets["you_got_credits_tv"].text = credits_message.html_safe
    #   outlets["you_got_credits_tv"].addTarget(self, action: "use_available_credits")
    # else
    #   credits_message = get_string("no_credits_for_establishment") % [self.establishment[:name], "#{Utils.format_money_br(self.establishment.credits_amount)}"]
    #   outlets["you_got_credits_tv"].text = credits_message
    # end
    # unless self.establishment.photo_url == "/images/original/missing.png"
    #   Utils.insert_photo_for_circle_view(getActivity, {photo: self.establishment.photo_url, image_view: outlets["establishment_image"]})
    # end
  end

  def show_choose_wallet_dialog
    ChooseWalletFragment.new_instance(self, self.wallets).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def create_open_billing
    self.is_open_billing = true
    change_layout LAYOUT_PAY_OR_REQUEST
  end

  def pay_establishment(establishment_index)
    self.establishment = self.establishments[establishment_index]
    change_layout LAYOUT_PAY_ESTABLISHMENTS
  end

  # def use_available_credits
  #   outlets["establishments_info_container"].set_gone
  #   if !establishment.nil?
  #     self.discount_id = establishment[:current_discount_id]
  #     self.discount_amount = establishment[:user_discount_amount]
  #   end
  # end

  def create_dormant_transaction(profile_index)
    self.is_dormant_billing = true
    change_layout LAYOUT_PAY_OR_REQUEST
  end

  def dismiss_no_account_message
    outlets["no_account_alert_container"].set_gone
  end

  def search_text_changed
      search_text = outlets["pay_or_request_users_name"].text_as_string
      last_query = search_text.split(",")[-1]
      profile_search_request(last_query.lstrip.rstrip) if !last_query.nil? && last_query.lstrip.rstrip.length > 0
  end

  def add_profile_to_transaction(profile_index)
    unless self.selected_profiles.any?{|p| p.remote_id == self.profiles[profile_index].remote_id}
      self.selected_profiles << self.profiles[profile_index]
    end
    set_profile_search_text
  end

  def set_profile_search_text
    search_text = self.selected_profiles.collect{|p| p.full_name.split(" ")[0]}.join(", ") 
    if self.selected_profiles.length > 0
      search_text += ", "
    end

    set_search_text search_text
    outlets["pay_or_request_users_name"].setSelection(outlets["pay_or_request_users_name"].text.length)
  end

  def set_search_text(text)
    getActivity.show_hide_menu_item('action_check', self.selected_profiles.length > 0 ? true : false)
    outlets["pay_or_request_users_name"].removeTextChangedListener(@text_listener)
    outlets["pay_or_request_users_name"].text = text
    outlets["pay_or_request_users_name"].addTextChangedListener(@text_listener)
  end

  def clear_profile_search
    if self.selected_profiles.length > 0
      self.selected_profiles.pop
      outlets["pay_or_request_users_name"].requestFocus
      set_payment_value_factor(nil, false)
    end

    if self.selected_profiles.length < 1
      change_layout LAYOUT_ESTABLISHMENT
    end
    set_profile_search_text
  end

  def wallet_changed(i)
    self.wallet = self.wallets[i]
    outlets["currency_prefix"].text = self.wallet.wallet_type.currency.short_name
    set_send_payment_state
  end

  def set_wallet_from_storage
    self.wallet = app_delegate.default_wallet
    outlets["currency_prefix"].text = self.wallet.wallet_type.currency.short_name
    set_send_payment_state
  end

  def set_payment_value_factor(view, has_focus)
    not_blank = self.amount_field.text_as_string.length > 0
    if !has_focus && self.selected_profiles.length > 1 && not_blank
      # value_text = self.amount_field.text_as_string
      # puts "#{self.amount_field.text_as_string}"
      # value_text += " x #{self.selected_profiles.length}"
      # puts "#{value_text}"
      # self.amount_field.text = value_text.toString
    elsif has_focus || self.selected_profiles.length < 2
      # value_text = self.amount_field.text_as_string
      # self.amount_field.text = value_text
    end
  end

  def send_payment
    amount = self.amount_field.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f

    if amount <= 0
       # Utils.show_dialog(getActivity, "Error", "Please enter valid amount")
    else
      balance = self.wallet.balance
      if !balance.nil? && balance > 0
        self.transaction_type = 'transaction_request'
        create_rapd_transaction
      else
        dialog = NoBalanceFragment.new_instance
        dialog.show(getActivity.getSupportFragmentManager, "no_balance_dialog")
      end
    end

  end

  def request_payment
    amount = self.amount_field.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f

    if amount <= 0
      Utils.show_dialog(getActivity, "Error", "Please enter valid amount")
    else
      self.successful = true
      self.transaction_type = 'deposit_request'
      # create_rapd_transaction
      create_transaction_request
    end

  end

  def gather_profile_ids
    if !self.establishment.nil?
      self.rapd_transaction.to_profile_id = self.establishment.remote_id
    elsif !self.selected_profiles.nil?
      self.rapd_transaction.to_profile_ids = self.selected_profiles.each.inject([]){|ids, p| ids << p.remote_id}
    end
  end

  def create_rapd_transaction
    self.rapd_transaction = RapdTransaction.new
    gather_profile_ids unless self.is_open_billing
    self.rapd_transaction.from_profile_id = app_delegate.current_profile_id
    amount = self.amount_field.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    # puts "#{amount}"
    self.rapd_transaction.amount = amount
    self.rapd_transaction.transaction_description = outlets["pay_or_request_comments"].text_as_string
    self.rapd_transaction.from_wallet_id = self.wallet.id
    self.rapd_transaction.rapd_transaction_type = self.transaction_type

    manager = RapdTransactionManager.shared_manager
    manager.delegate = self
    manager.create_resource(self.rapd_transaction)
  end

  def create_transaction_request
    amount = self.amount_field.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    # puts "#{amount}, #{self.selected_profiles.first.remote_id}"
    transaction_request = TransactionRequest.new
    transaction_request.from_profile_id = app_delegate.current_profile_id
    if self.selected_profiles.first != nil
      puts "Using profiles"
      transaction_request.to_profile_id = self.selected_profiles.first.remote_id
    else
      puts "Using establishments"
      transaction_request.to_profile_id = self.establishment.remote_id
    end
    transaction_request.amount = amount
    transaction_request.request_description = outlets["pay_or_request_comments"].text_as_string
    transaction_request.currency_id = self.wallet.wallet_type.currency_id
    transaction_request.status = "pending"

    manager = TransactionRequestManager.shared_manager
    manager.delegate = self
    manager.create_resource(transaction_request)
  end

  def resource_created
    # if is_open_billing
    #   show_confirmation_dialog false
    # else
    #   go_back
    # end
    show_confirmation_dialog self.transaction_type == "transaction_request"
  end

  def resource_creation_failed
  end

  def make_another_payment
    self.is_open_billing = false
    self.is_dormant_billing = false
    unlock_fields_after_confirmation
    change_layout LAYOUT_ESTABLISHMENT
  end

  def make_another_request
    self.is_dormant_billing = false
    unlock_fields_after_confirmation
    change_layout LAYOUT_PAY_OR_REQUEST
  end

  def finish
    @dialog.dismiss
    go_back
  end

  def lock_fields_before_confirmation
    self.amount_field.setFocusable(false)
    outlets["pay_or_request_comments"].setFocusable(false)
    outlets["pay_or_request_users_name"].setFocusable(false)
    outlets["value_bottom_border"].set_invisible
    outlets["comment_bottom_border"].set_invisible
    outlets["pay_or_request_separator"].set_gone
    outlets["pay_or_request_buttons"].set_invisible
    outlets["establishments_info_container"].set_gone
  end

  def unlock_fields_after_confirmation
    unless @dialog.nil?
      @dialog.dismiss
      @dialog = nil
    end
    self.amount_field.setFocusable(true)
    outlets["pay_or_request_comments"].setFocusable(true)
    outlets["pay_or_request_users_name"].setFocusable(true)
    self.amount_field.setFocusableInTouchMode(true)
    outlets["pay_or_request_comments"].setFocusableInTouchMode(true)
    outlets["pay_or_request_users_name"].setFocusableInTouchMode(true)
  end

  def show_confirmation_dialog(payment_made)
    lock_fields_before_confirmation
    @dialog = PayOrRequestFinishedDialogFragment.newInstance(*get_values_for_dialog(payment_made))
    @dialog.show(getActivity().getSupportFragmentManager(), "dialog")
  end

  def get_values_for_dialog(payment_made)
    amount = self.amount_field.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    if is_open_billing
      value = amount
    # elsif is_dormant_billing
    #   value = outlets["pay_or_request_value"].text_as_string.to_f
    #   recipient = outlets["pay_or_request_users_name"].text_as_string
    elsif !(selected_profiles.length > 0)
      value = amount
      recipient = "@#{establishment.full_name}"
    else
      value = amount * selected_profiles.length
      recipient = selected_profiles_dialog_text
    end

    if is_open_billing
      message = get_string("successfully_requested_open_payment") % "#{self.wallet.wallet_type.currency.short_name} #{Utils.format_money(value)}"
    # elsif is_dormant_billing
    #   message = get_string("successfully_sent_dormant_payment") % Utils.format_money_br(value)
    else
      message = get_string(payment_made ? "successfully_sent_payment" : "successfully_requested_payment") % ["#{self.wallet.wallet_type.currency.short_name} #{Utils.format_money(value)}", recipient]
    end

    credits_earned = 2
    [
      self, 
      successful, 
      message,
      self.is_open_billing ? "make_another_request" : "make_another_payment", 
      "finish", 
      # !establishment.nil? && (discount_amount.nil? || discount_amount == 0), 
      # !establishment.nil? && !establishment[:user_discount_amount].nil? ? establishment[:user_discount_amount] : 0,
      credits_earned,
      is_open_billing,
      is_dormant_billing,
      {open_billing_link: "http://rapd.in/98ad+8a9d", amount: value}
    ]
  end

  def selected_profiles_dialog_text
    if(selected_profiles.length > 2)
      text = selected_profiles[0...(selected_profiles.length-1)].collect{|p| p.full_name.split(" ")[0]}.join(", ") 
      text += " e #{selected_profiles[selected_profiles.length-1].full_name.split(" ")[0]}"
    elsif(selected_profiles.length > 1)
      text = selected_profiles.collect{|p| p.full_name.split(" ")[0]}.join(" e ") 
    else
      text = selected_profiles[0].full_name.split(" ")[0]
    end
    text
  end

  def profile_search_request(query)
    if !@is_establishment
      manager = PersonManager.shared_manager
      manager.delegate = self
      manager.fetch_all({"search[name]" => query}, "profile_search_response")
    end
  end

  def profile_search_response(profiles)
    self.profiles = profiles
    @profile_adapter.set_data(people_rows(self.profiles)[:rows])
    change_layout LAYOUT_PROFILES
    if outlets["pay_or_request_users_name"].text_as_string.length > 0
      outlets["pay_or_request_img_clear"].set_visible
    else
      outlets["pay_or_request_img_clear"].set_gone
      change_layout LAYOUT_ESTABLISHMENT unless self.current_layout == LAYOUT_ESTABLISHMENT
    end
  end

  def load_nearby_establishments
    manager = EstablishmentManager.shared_manager   
    manager.delegate = self
    manager.fetch_all({}, "establishments_fetched")
  end

  def establishments_fetched(establishments)
    self.establishments = establishments
    @establishment_adapter = NearbyEstablishmentAdapter.new(self, establishment_rows(self.establishments)[:rows])
    outlets["pay_or_request_list_view"].adapter = @establishment_adapter
  end

  def load_wallets
    if app_delegate.default_wallet.nil?
      wallet_manager = WalletManager.shared_manager
      wallet_manager.delegate = self
      wallet_manager.fetch_all({profile_id: app_delegate.current_profile_id}, "wallets_fetched")
    else
      set_wallet_from_storage
    end
  end

  def wallets_fetched(wallets)
    self.wallets = wallets
    set_wallet_from_storage
  end

  def people_rows(people)
    rows = []
    people.each do |person|
      rows << {cell_type: 'custom_row_pay_or_request', full_name: person.full_name, email: person.email, username: person.username, photo_url: person.photo_url}
    end
    {rows: rows}
  end

  def establishment_rows(establishments)
    rows = []
    establishments.each do |establishment|
      rows << {cell_type: 'custom_row_pay_or_request', name: establishment.full_name, distance: "#{rand(410)} m", photo_url: establishment.photo_url}
    end
    {rows: rows}
  end
end
