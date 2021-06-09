class ConvertCurrencyFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :currencies, :currency_names, :from_currency, :to_currency,
                :from_amount, :to_amount, :wallets, :wallet, :btn_from_wallet, :btn_to_wallet, :edt_amount

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "convert_currency_title"
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def onClick(view)
    super
  end

  def load_views
    @currency_manager = CurrencyManager.shared_manager
    @currency_manager.delegate = self
    self.btn_from_wallet = outlets["change_from_wallet"].addTarget(self, action: "change_from_wallet")
    self.btn_to_wallet = outlets["change_to_wallet"].addTarget(self, action: "change_to_wallet")
    self.edt_amount = outlets["amount"]
    outlets["convert_button"].addTarget(self, action: "confirm_conversion")
    outlets["convert_button"].setClickable false
    self.edt_amount.addTextChangedListener(NumberTextWatcher.new(self, self.edt_amount, "amount_text_changed"))
  end

  def change_from_wallet
    @isFromWallet = true
    ChooseWalletFragment.new_instance(self, self.wallets).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def change_to_wallet
    @isFromWallet = false
    ChooseWalletFragment.new_instance(self, self.wallets).show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def wallet_changed(i)
    self.wallet = wallets[i]
    text = "#{wallet.wallet_type.currency.short_name} - #{wallet.wallet_type.currency.name}"
    if @isFromWallet
      outlets["change_from_wallet"].text = "Alterar Carteira - " + text
      self.from_currency = wallet.wallet_type.currency
    else
      outlets["change_to_wallet"].text = "Alterar Carteira - " + text
      self.to_currency = wallet.wallet_type.currency
    end
    preview_conversion
  end

  def amount_text_changed
    if app_delegate.current_profile_id != nil && self.from_currency != nil && self.to_currency != nil
      preview_conversion
    end
  end

  def valid_conversion?
    if app_delegate.current_profile_id != nil && self.from_currency.id != nil && self.to_currency.id != nil && self.from_amount != nil && self.to_amount != nil
      wallet = self.wallets.each.inject([]){|of_currency, w| of_currency << w if w.wallet_type.currency.short_name.to_s == from_currency.short_name.to_s; return of_currency}
      wallet = wallet[0]
      if wallet.present? && wallet.balance.to_f > self.outlets["converted_amount"].text_as_string.to_f
        true
      else
        false
      end
    end
  end

  def preview_conversion
    outlets["convert_button"].setClickable true
    amount = outlets["amount"].text_as_string
    amount = amount.gsub(/[.]/,'')
    amount = amount.gsub(/[,]/, ".")
    self.from_amount = amount
    if amount.to_f > 0 && app_delegate.current_profile_id != nil && self.from_currency != nil && self.to_currency != nil
      @currency_manager.convert(amount: amount,to_currency_id: self.to_currency.id, from_currency_id: self.from_currency.id, buying: 0, needs_normalization: 1)
    end
  end

  def currency_converted(data)
    outlets["converted_amount"].text = "#{to_currency.short_name} #{Utils.format_money(data['to_amount'])}"
    # puts "From amount #{data["from_amount"]}"
    # puts "To amount #{data["to_amount"]}"
    self.to_amount = data["to_amount"]
  end

  def confirm_conversion
    Utils.show_confirm_dialog(getActivity, self, "dialogButtonClicked")
  end

  def dialogButtonClicked(id)
    if id == -1
      create_conversion_request
    end
  end

  def create_conversion_request
    @dialog = Utils.loading_dialog getActivity
    preview_conversion
    if valid_conversion?
      conversion_request = ConversionRequest.new
      conversion_request.profile_id = app_delegate.current_profile_id
      conversion_request.from_currency_id = self.from_currency.id
      conversion_request.to_currency_id = self.to_currency.id
      conversion_request.from_amount = self.from_amount
      conversion_request.to_amount = self.to_amount

      manager = ConversionRequestManager.shared_manager
      manager.delegate = self
      manager.create_resource(conversion_request)
    else
      @dialog.dismiss
      Utils.show_dialog(getActivity, "Erro", "Não há saldo o suficiente para realizar esta conversão")
    end
  end

  def resource_created(conversion_request)
    @dialog.dismiss
    go_back
  end

  def resource_creation_failed
    @dialog.dismiss
  end
end