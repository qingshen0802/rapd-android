class BankTransferFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :transaction, :bank_accounts, :selected_bank_account

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "bank_transfer"
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
    load_bank_accounts
    summary_text = get_string("transfer_summary") % ["#{self.transaction.wallet.wallet_type.currency.short_name} #{self.transaction.human_amount}"]
    outlets["transfer_summary"].text = summary_text
    outlets["upload_reciept"].addTarget(self, action: "upload_reciept")
    outlets["ok"].addTarget(self, action: "on_toolbar_back_pressed")
  end

  def set_bank_spinner
    adapter = SpinnerAdapter.new(getActivity, bank_names, "custom_row_spinner_item_white_left")
    outlets["bank_spinner"].adapter = adapter
    outlets["bank_spinner"].setOnItemSelectedListener(ItemSelectedListener.new(self, "select_bank"))
  end

  def set_bank_details
    outlets["bank_name"].text = selected_bank_account.bank_name
    outlets["branch"].text = get_string("branch") % "#{selected_bank_account.branch_number}-#{selected_bank_account.branch_digit}"
    outlets["type_and_number"].text = "#{abbreviated_bank_type}: #{selected_bank_account.account_number}-#{selected_bank_account.account_digit}"
    outlets["identifier"].text = get_string("bank_identifier") % identifier
    outlets["company_text"].text = get_string("company_text")
    outlets["cnpj_number"].text = get_string("cnpj_number") % cnpj_number
  end

  def bank_names
    names = []
    bank_accounts.each{|b| names << (b.bank_name.downcase.include?("banco") ? b.bank_name : "Banco #{b.bank_name}")}
    names
  end

  def abbreviated_bank_type
    case selected_bank_account.account_type
    when 'Conta Corrente'
      'C/C'
    when 'Conta Poupança'
      'C/P'
    end
  end

  def select_bank(i)
    self.selected_bank_account = self.bank_accounts[i]
    set_bank_details
  end

  def upload_reciept
    switch_to_fragment("upload_reciept", container: "main", fragment_attributes: {transaction: self.transaction})
  end

  def identifier
    "389"
  end

  def cnpj_number
    "209.209.298/0001-10"
  end

  def load_bank_accounts
    bank_account_manager = BankAccountManager.shared_manager
    bank_account_manager.delegate = self
    bank_account_manager.fetch_all()
  end

  def items_fetched(bank_accounts)
    self.bank_accounts = bank_accounts
    self.selected_bank_account = bank_accounts.first
    if selected_bank_account != nil
      set_bank_details
      set_bank_spinner
    end
  end
end