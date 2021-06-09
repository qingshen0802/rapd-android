class BankInstallmentFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :transaction, :amount_in_real

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "bank_slip"
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

  def load_views
    if amount_in_real == nil
      human_amount = "#{transaction.wallet.wallet_type.currency.short_name} #{transaction.human_amount}"
      outlets["bank_slip_value"].text = human_amount
    else
      human_amount = "R$ #{amount_in_real}"
      outlets["bank_slip_value"].text = human_amount
    end
    outlets["bank_slip_code"].text = transaction.bank_installment_code
    outlets["bank_slip_expiration"].text = transaction.expires_at
    outlets["send_bank_slip_to_email"].text = get_string("send_bank_slip_to_email") % [human_amount, transaction.expires_at, app_delegate.current_profile.email]
    outlets["confirm_payment_button"].addTarget(self, action: "on_toolbar_back_pressed")
  end

  def on_toolbar_back_pressed
    if !back_destination.nil?
      go_back_to_fragment back_destination
      true
    else
      false
    end
  end

end