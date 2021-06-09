class SelectPaymentTypeFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :amount, :wallet_id, :currency_id

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def get_title
    get_string "select_payment_type_title"
  end

  def onClick(view)
    super view
  end

  def load_views
    outlets["select_payment_type_bank_container"].addTarget(self, action: "withdraw_request", "bank_transfer")
    outlets["select_payment_type_dedit_container"].addTarget(self, action: "withdraw_request", "debit_card")
  end

  def withdraw_request(option)
    @dialog = Utils.loading_dialog(getActivity)
    # puts "#{currency_id}"
    withdraw_request = WithdrawalRequest.new({
      amount: amount,
      currency_id: currency_id,
      profile_id: app_delegate.current_profile_id,
      request_type: "#{option}",
      wallet_id: wallet_id
    })
    withdraw_manager = WithdrawalRequestManager.shared_manager
    withdraw_manager.delegate = self
    withdraw_manager.create_resource withdraw_request
  end

  def resource_created(withdraw_request)
    @dialog.dismiss
    switch_to_fragment("withdrew_successfully", container: "main", fragment_attributes: {human_amount: withdraw_request.human_amount})
  end

  def resource_creation_failed
    @dialog.dismiss
    Utils.show_dialog(getActivity, "Erro", "Withdraw Request Failed")
  end

end