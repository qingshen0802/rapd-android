class AcceptPaymentRequestFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :notification, :transaction_request, :wallet, :wallets, :currency_id

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string 'pay_or_request_title'
  end

  def load_views
    # puts "#{self.transaction_request.to_json}"
    @txt_user_name = outlets['text_requester_name']
    @txt_amount = outlets['text_amount']
    @txt_comment = outlets['text_comment']
    @txt_currency = outlets['text_currency_prefix']
    @btn_change_wallet = outlets['show_change_wallet']
    @btn_accept = outlets['accept_payment_button']
    @btn_decline = outlets['decline_payment_button']

    @btn_change_wallet.setOnClickListener(self)
    @btn_accept.setOnClickListener(self)
    @btn_decline.setOnClickListener(self)

    @txt_user_name.text = self.transaction_request.to_profile['full_name'].to_s
    @txt_amount.text = Utils.format_money(self.transaction_request.amount.to_s)
    @txt_comment.text = self.transaction_request.request_description.to_s
    self.currency_id = self.transaction_request.currency_id.to_s
    load_currencies
  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  def onClick(button)
    if button == @btn_accept
      puts "Payment agreed"
      accept_request
    elsif button == @btn_decline
      puts "Payment Canceled"
    elsif button == @btn_change_wallet
      show_choose_wallet_dialog
    end
  end

  def show_choose_wallet_dialog
    ChooseWalletFragment.new_instance(self, self.wallets, nil, self.currency_id).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def wallet_changed(i)
    self.wallet = self.wallets[i]
  end

  def load_currencies
    @currency_manager = CurrencyManager.shared_manager
    @currency_manager.delegate = self
    @currency_manager.fetch_all({}, "currencies_fetched", true)
  end

  def currencies_fetched(currencies)
    currencies.each { |object|
      if object.id == self.currency_id
        @txt_currency.text = object.short_name.to_s
      end
    }
  end
  
  def locale(date)
    usa = Java::Text::SimpleDateFormat.new("yyyy-MM-dd", Java::Util::Locale::US)
    formattedDateUSA = usa.parse(date)
    dateFormat = Java::Text::SimpleDateFormat.new("dd/MM/yyyy", Java::Util::Locale::US)
    formattedDate = dateFormat.format(formattedDateUSA)
    formattedDate
  end

  def accept_request
    if self.wallet == nil
      Utils.show_dialog(getActivity, "Alert", "You need to choose wallet.")
    else
      if self.wallet.balance >= self.transaction_request.amount
        make_payment
      else
        Utils.show_dialog(getActivity, "Alert", "There is no enough money in your wallet!")
      end
    end
  end

  def make_payment
    @dialog = Utils.loading_dialog getActivity
    rapd_transaction = RapdTransaction.new
    rapd_transaction.from_profile_id = app_delegate.current_profile_id
    rapd_transaction.to_profile_id = self.transaction_request.from_profile_id
    rapd_transaction.amount = self.transaction_request.amount.to_f * 100 / 100.00
    rapd_transaction.transaction_description = self.transaction_request.request_description
    rapd_transaction.from_wallet_id = self.wallet.id
    rapd_transaction.rapd_transaction_type = "deposit_request"

    manager = RapdTransactionManager.shared_manager
    manager.delegate = self
    manager.create_resource(rapd_transaction)
  end

  def resource_created
    update_transaction_reqeust
  end

  def resource_creation_failed
    @dialog.dismiss
    Utils.show_dialog(getActivity, "Error", "Please try again!")
  end

  def update_transaction_reqeust
    self.transaction_request.status = "processed"
    self.transaction_request.to_profile_id = self.transaction_request.from_profile_id
    self.transaction_request.from_profile_id = app_delegate.current_profile_id
    request_udpate_manager = TransactionRequestManager.shared_manager
    request_udpate_manager.delegate = self
    request_udpate_manager.update_resource(self.transaction_request)
  end

  def resource_updated(element)
    @dialog.dismiss
    go_back
  end

  def resource_update_failed
    @dialog.dismiss
    Utils.show_dialog(getActivity, "Error", "Please try again!")
  end
end