class PartnerPaymentFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager
  attr_accessor :profile, :wallet, :wallets, :transaction_type

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string 'pay_or_request_title'
  end

  def load_views
    @txt_user_name = outlets['text_requester_name']
    @txt_amount = outlets['pay_or_request_value']
    @txt_comment = outlets['pay_or_request_comments']
    @txt_currency = outlets['text_currency_prefix']
    @btn_change_wallet = outlets['show_change_wallet']
    @btn_request = outlets['accept_payment_button']
    @btn_send = outlets['decline_payment_button']

    @txt_amount.addTextChangedListener(NumberTextWatcher.new(self, @txt_amount, nil))

    @btn_change_wallet.setOnClickListener(self)
    @btn_send.setOnClickListener(self)
    @btn_request.setOnClickListener(self)

    @txt_user_name.text = self.profile.full_name.to_s
    self.wallet = app_delegate.default_wallet
    @txt_currency.text = self.wallet.wallet_type.currency.short_name.to_s
    # load_currencies
  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  def onClick(button)
    if button == @btn_request
      request_payment
    elsif button == @btn_send
      send_payment
    elsif button == @btn_change_wallet
      show_choose_wallet_dialog
    end
  end

  def show_choose_wallet_dialog
    ChooseWalletFragment.new_instance(self, self.wallets, nil).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def wallet_changed(i)
    self.wallet = self.wallets[i]
    @txt_currency.text = self.wallet.wallet_type.currency.short_name.to_s
  end

  def send_payment
    balance = self.wallet.balance
    if !balance.nil? && balance > 0
      self.transaction_type = 'transaction_request'
      create_rapd_transaction
    else
      dialog = NoBalanceFragment.new_instance
      dialog.show(getActivity.getSupportFragmentManager, "no_balance_dialog")
    end
  end

  def request_payment
    self.successful = true
    self.transaction_type = 'deposit_request'
    # create_rapd_transaction
    create_transaction_request
  end

  def create_rapd_transaction
    @dialog = Utils.loading_dialog getActivity
    @rapd_transaction = RapdTransaction.new
    @rapd_transaction.from_profile_id = app_delegate.current_profile_id
    @rapd_transaction.to_profile_id = self.profile.remote_id
    amount = @txt_amount.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    # puts "#{amount}"
    @rapd_transaction.amount = amount
    @rapd_transaction.transaction_description = @txt_comment.text_as_string
    @rapd_transaction.from_wallet_id = self.wallet.id
    @rapd_transaction.rapd_transaction_type = self.transaction_type

    manager = RapdTransactionManager.shared_manager
    manager.delegate = self
    manager.create_resource(@rapd_transaction)
  end

  def create_transaction_request
    @dialog = Utils.loading_dialog getActivity
    amount = @txt_amount.text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    # puts "#{amount}, #{self.selected_profiles.first.remote_id}"
    transaction_request = TransactionRequest.new
    transaction_request.from_profile_id = app_delegate.current_profile_id
    transaction_request.to_profile_id = self.profile.remote_id
    transaction_request.amount = amount
    transaction_request.request_description = @txt_comment.text_as_string
    transaction_request.currency_id = self.wallet.wallet_type.currency_id
    transaction_request.status = "pending"

    manager = TransactionRequestManager.shared_manager
    manager.delegate = self
    manager.create_resource(transaction_request)
  end

  def resource_created
    @dialog.dismiss
    # show_confirmation_dialog self.transaction_type == "transaction_request"
    go_back
  end

  def resource_creation_failed
  end

  # def show_confirmation_dialog(payment_made)
  #   lock_fields_before_confirmation
  #   @dialog = PayOrRequestFinishedDialogFragment.newInstance(*get_values_for_dialog(payment_made))
  #   @dialog.show(getActivity().getSupportFragmentManager(), "dialog")
  # end

  def lock_fields_before_confirmation
    @txt_amount.setFocusable(false)
    @txt_comment.setFocusable(false)
    @btn_change_wallet.set_gone
  end

  # def get_values_for_dialog(payment_made)
  #   amount = @txt_amount.text_as_string
  #   amount = amount.gsub(/[.]/,'')
  #   amount = amount.gsub(/[,]/, ".").to_f
  #   value = amount
  #   recipient = "@#{profile.full_name}"
  #
  #   # if is_open_billing
  #   #   message = get_string("successfully_requested_open_payment") % "#{self.wallet.wallet_type.currency.short_name} #{Utils.format_money(value)}"
  #   #   # elsif is_dormant_billing
  #   #   #   message = get_string("successfully_sent_dormant_payment") % Utils.format_money_br(value)
  #   # else
  #     message = get_string(payment_made ? "successfully_sent_payment" : "successfully_requested_payment") % ["#{self.wallet.wallet_type.currency.short_name} #{Utils.format_money(value)}", recipient]
  #   # end
  #
  #   credits_earned = 2
  #   [
  #       self,
  #       successful,
  #       message,
  #       "finish",
  #       # !establishment.nil? && (discount_amount.nil? || discount_amount == 0),
  #       # !establishment.nil? && !establishment[:user_discount_amount].nil? ? establishment[:user_discount_amount] : 0,
  #       credits_earned,
  #       {open_billing_link: "http://rapd.in/98ad+8a9d", amount: value}
  #   ]
  # end
end