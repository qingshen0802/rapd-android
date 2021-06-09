class AddCreditCardFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :credit_card, :addresses, :profile

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "add_cc_title"
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
    outlets["web_view"].getSettings.setJavaScriptEnabled true
    outlets["web_view"].addJavascriptInterface(PagarmeWebInterface.new(getActivity.getContext, self), "Android")
    outlets["web_view"].setWebChromeClient(Android::Webkit::WebChromeClient.new)
    outlets["web_view"].clearCache true
    outlets["web_view"].loadUrl "file:///android_asset/pagarme_web_form.html"

    self.credit_card = CreditCard.new
    load_addresses
    outlets["save"].addTarget(self, action: "create_card")
    outlets["card_io_image"].addTarget(self, action: "start_card_io_scan")

    outlets["card_owner_edit"].text = profile.full_name
  end

  def start_card_io_scan
    @scan_request_code = 1
    scan_intent = Android::Content::Intent.new(getActivity, Java::Lang::Class.forName("io.card.payment.CardIOActivity"))
    scan_intent.putExtra(Io::Card::Payment::CardIOActivity::EXTRA_REQUIRE_EXPIRY, true)
    scan_intent.putExtra(Io::Card::Payment::CardIOActivity::EXTRA_REQUIRE_CVV, true)
    scan_intent.putExtra(Io::Card::Payment::CardIOActivity::EXTRA_REQUIRE_POSTAL_CODE, false)
    scan_intent.putExtra(Io::Card::Payment::CardIOActivity::EXTRA_USE_CARDIO_LOGO, true)
    scan_intent.putExtra(Io::Card::Payment::CardIOActivity::EXTRA_LANGUAGE_OR_LOCALE, "pt_BR")
    startActivityForResult(scan_intent, @scan_request_code)
  end

  def onActivityResult(req_code, res_code, data)
    super
    if req_code == @scan_request_code
      if !data.nil? && data.hasExtra(Io::Card::Payment::CardIOActivity::EXTRA_SCAN_RESULT)
        result = data.getParcelableExtra(Io::Card::Payment::CardIOActivity::EXTRA_SCAN_RESULT)
        self.credit_card.number = result.cardNumber unless result.cardNumber.nil?
        self.credit_card.last_four_digits = result.cardNumber[-4..-1] unless result.cardNumber.nil?
        self.credit_card.expiry_date = "#{result.expiryMonth.to_s}/#{result.expiryYear.to_s[-2..-1]}" if result.isExpiryValid
        self.credit_card.cvv = result.cvv unless result.cvv.nil?
        fill_fields_from_card_io
      end
    end
  end

  def fill_fields_from_card_io
    outlets["card_number_edit"].text = "**** **** **** %s" % self.credit_card.last_four_digits
    outlets["due_date_edit"].text = self.credit_card.expiry_date
    outlets["security_code_edit"].text = "*" * self.credit_card.cvv.length
  end

  def set_spinner(addresses)
    short_addresses = addresses.each.inject([]){|shorts, address| shorts << address.short_address}
    outlets["addresses_spinner"].adapter = SpinnerAdapter.new(getActivity, short_addresses, "custom_row_spinner_address")
    outlets["addresses_spinner"].setOnItemSelectedListener(ItemSelectedListener.new(self, "set_address"))
  end

  def set_address(i)
    self.credit_card.address_id = addresses[i].remote_id
  end

  def card_hash_generated(card_hash)
    self.credit_card.card_hash = card_hash
    self.credit_card.number = nil
    self.credit_card.cvv = nil
    self.credit_card.profile_id = app_delegate.current_profile_id

    cc_manager = CreditCardManager.shared_manager
    cc_manager.delegate = self
    cc_manager.create_resource(self.credit_card)
  end

  def resource_created(credit_card)
    @dialog.dismiss
    go_back
  end

  def resource_creation_failed
    @dialog.dismiss
  end

  def create_card
    self.credit_card.name_on_card ||= outlets["card_owner_edit"].text_as_string
    self.credit_card.number ||= outlets["card_number_edit"].text_as_string
    self.credit_card.last_four_digits ||= outlets["card_number_edit"].text_as_string.to_s[-4..-1]
    self.credit_card.expiry_date ||= outlets["due_date_edit"].text_as_string
    self.credit_card.cvv ||= outlets["security_code_edit"].text_as_string
    self.credit_card.autodetect_type
    self.credit_card.user_id = self.profile.user_id
    self.credit_card.profile_id = self.profile.id

    @dialog = Utils.loading_dialog getActivity
    request_card_hash
  end

  def request_card_hash
    exp_date = credit_card.expiry_date.split(/[^0-9]/)
    exp_mo = exp_date[0]
    exp_yr = exp_date[1] if exp_date.length > 1
    if !/\A\d+\z/.match(exp_mo) || !/\A\d+\z/.match(exp_yr)
      puts "Error"
      present_error
    else
      self.credit_card.expiry_date = "20#{exp_yr}-#{exp_mo}-01"
      cc_manager = CreditCardManager.shared_manager
      cc_manager.delegate = self
      cc_manager.create_resource(self.credit_card)
      # javascript =
      #   "$(\"#payment_form #card_holder_name\").val('" + credit_card.name_on_card + "');" +
      #   "$(\"#payment_form #card_expiration_month\").val('" + exp_mo + "');" +
      #   "$(\"#payment_form #card_expiration_year\").val('" + exp_yr + "');" +
      #   "$(\"#payment_form #card_number\").val('" + credit_card.number + "');" +
      #   "$(\"#payment_form #card_cvv\").val('" + credit_card.cvv + "');" +
      #   "$(\"#payment_form\").submit();"
      # puts "Loading url#{exp_mo}, #{exp_yr}, #{javascript}"
      # outlets["web_view"].loadUrl("javascript: " + javascript)
    end
  end

  def card_hash_gen_error
    present_error
  end

  def present_error
    @dialog.dismiss if !@dialog.nil? && @dialog.isShowing
    Utils.show_dialog(getActivity, "Tratto", "Não foi possível validar o seu cartão de crédito, confira os dados e tente novamente.")
  end

  def load_addresses
    address_manager = AddressManager.shared_manager
    address_manager.delegate = self
    address_manager.fetch_all({profile_id: app_delegate.current_profile_id})
  end

  def items_fetched(addresses)
    self.addresses = addresses
    set_spinner addresses
  end
end