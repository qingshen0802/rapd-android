class LoadMoneyFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  BRAZILIAN_REAL_ID = 1

  attr_accessor :transaction, :currency_manager, :wallets, :wallet, :amount_field, :amount_in_real

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def has_actionbar?
    true
  end

  def onClick(view)
    super view
  end
  
  def get_title
    get_string "load_funds"
  end
  
  def has_back_arrow?
    true
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
    self.transaction = Transaction.new(profile_id: app_delegate.current_profile_id)
    self.currency_manager = CurrencyManager.shared_manager
    currency_manager.delegate = self
    outlets["change_wallet"].addTarget(self, action: "change_wallet")
    set_transaction_type 0
    self.amount_field = outlets["amount"]
    self.amount_field.addTextChangedListener(NumberTextWatcher.new(self, self.amount_field, "show_equivalent_in_real"))

    outlets["deadlines_and_fees_button"].addTarget(self, action: "rates_and_deadlines")
    outlets["load_money_button"].addTarget(self, action: "load_money")
    
    set_transaction_type_spinner
  end

  def change_wallet
    ChooseWalletFragment.new_instance(self, self.wallets).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def wallet_changed(i)
    self.wallet = wallets[i]
    text = "#{wallet.wallet_type.currency.short_name} - #{wallet.wallet_type.currency.name}"
    outlets["change_wallet"].text = "Alterar Carteira - " + text
    show_equivalent_in_real
  end

  def set_transaction_type_spinner
    adapter = SpinnerAdapter.new(getActivity, transaction_types, "custom_row_spinner_item_pale_blue_background")
    outlets["transaction_type_spinner"].adapter = adapter
    outlets["transaction_type_spinner"].setOnItemSelectedListener(ItemSelectedListener.new(self, "set_transaction_type"))
  end

  def load_money
    amount = outlets["amount"].text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".").to_f
    self.transaction.amount_in_cents = (amount * 100).to_i
    case self.transaction.transaction_type
    when remote_transaction_types[0]
      self.transaction.should_charge = "1"
    when remote_transaction_types[1]
      # self.transaction.should_charge = "1"
    # when remote_transaction_types[2]
    end

    create_transaction
  end

  def create_transaction
    if self.wallet != nil
      @dialog = Utils.loading_dialog getActivity
      self.transaction.wallet_id = self.wallet.id
      transaction_manager = TransactionManager.shared_manager
      transaction_manager.delegate = self
      # puts "#{self.transaction.to_json}"
      transaction_manager.create_resource(self.transaction)
    end
  end

  def resource_created(transaction)
    @dialog.dismiss
    case transaction.transaction_type
    # when remote_transaction_types[0]
      # switch_to_fragment("credit_cards", container: "main", fragment_attributes: {transaction: transaction, back_destination: back_destination})
    when remote_transaction_types[0]
      if wallet.wallet_type.currency_id.to_i != BRAZILIAN_REAL_ID
        puts "Going with real amount"
        switch_to_fragment("bank_installment", container: "main", fragment_attributes: {transaction: transaction, amount_in_real: self.amount_in_real, back_destination: back_destination})
      else
        puts "Going with brazil amount"
        switch_to_fragment("bank_installment", container: "main", fragment_attributes: {transaction: transaction, amount_in_real: nil, back_destination: back_destination})
      end
    when remote_transaction_types[1]
      switch_to_fragment("bank_transfer", container: "main", fragment_attributes: {transaction: transaction, back_destination: back_destination})
    end
  end

  def resource_creation_failed
    @dialog.dismiss
  end

  def set_transaction_type(i)
    self.transaction.transaction_type = remote_transaction_types[i]
  end

  def transaction_types
    ["Boleto Bancário", "Transferência Bancária"]
  end

  def remote_transaction_types
    ["bank_installment", "bank_transfer"]
  end

  def rates_and_deadlines
    switch_to_fragment('deadlines_and_fees', container: 'main')
  end

  def show_equivalent_in_real
    amount = outlets["amount"].text_as_string
    amount = amount.gsub(/[.]/, '')
    amount = amount.gsub(/[,]/, ".").to_f
    if !amount.nil? && amount > 0 && wallet != nil && (wallet.wallet_type.currency_id.to_i != BRAZILIAN_REAL_ID)
      convert_currency(amount)
    else
      outlets["amount_in_real_container"].set_gone
    end
  end

  def convert_currency(amount)
    currency_manager.convert(amount: amount, to_currency_id: BRAZILIAN_REAL_ID, from_currency_id: wallet.wallet_type.currency_id, buying: 1, needs_normalization: 1)
  end

  def currency_converted(data)
    outlets["amount_in_real_container"].set_visible
    self.amount_in_real = data["to_amount"]
    outlets["amount_in_real"].text = get_string("amount_in_real") % Utils.format_money_br(data["to_amount"])
  end
end
