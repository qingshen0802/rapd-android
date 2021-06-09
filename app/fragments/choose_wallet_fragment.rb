class ChooseWalletFragment < Android::Support::V4::App::DialogFragment
  include BaseView
  include FragmentManager

  attr_accessor :delegate, :wallets, :title, :current_currency_id

  def self.new_instance(delegate, wallets = nil, title = nil, current_currency_id = nil)
    choose_wallet_frag = ChooseWalletFragment.new
    choose_wallet_frag.delegate = delegate
    choose_wallet_frag.wallets = wallets
    choose_wallet_frag.title = title
    choose_wallet_frag.current_currency_id = current_currency_id
    choose_wallet_frag
  end

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def onStart
    super
    dialog = getDialog
    dialog.setCancelable(true)
    FullScreenDialogFragmentHelper.on_start(dialog)
  end

  def onCreateDialog(savedInstanceState)
    dialog = super
    FullScreenDialogFragmentHelper.on_create_dialog(dialog, savedInstanceState)
  end

  def onClick(button)
    super button
  end

  def has_actionbar?
    false
  end

  def nested_fragment?
    true
  end

  def load_views
    if self.wallets.nil?
      load_wallets
    else
      items_fetched(self.wallets)
    end
  end

  def load_wallets
    wallet_manager = WalletManager.shared_manager
    wallet_manager.delegate = self
    wallet_manager.fetch_all(profile_id: app_delegate.current_profile_id)
  end

  def items_fetched(wallets_fetched)

    if self.delegate.class.to_s == 'WithdrawFragment'
      self.wallets = []
      wallets_fetched.each { |object|
        if object.wallet_type.withdrawable == true
          self.wallets << object
        end
      }
    elsif self.delegate.class.to_s == 'LoadMoneyFragment'
      self.wallets = []
      wallets_fetched.each { |object|
        if object.wallet_type.loadable == true
          self.wallets << object
        end
      }
    elsif self.delegate.class.to_s == 'ConvertCurrencyFragment'
      self.wallets = []
      wallets_fetched.each { |object|
        if object.wallet_type.conversionable == true
          self.wallets << object
        end
      }
    elsif self.delegate.class.to_s == 'AcceptPaymentRequestFragment'
      self.wallets = []
      wallets_fetched.each { |object|
        if object.wallet_type.currency_id.to_s == self.current_currency_id
          self.wallets << object
        end
      }
    else
      self.wallets = []
      wallets_fetched.each { |object|
        self.wallets << object
      }
    end
    self.delegate.wallets = self.wallets
    adapter = WalletAdapter.new(self, load_table_data[:rows])
    outlets["title"].text = self.title unless self.title.nil?
    outlets["wallets_list"].adapter = adapter
    outlets["dismiss"].addTarget(self, action: "close")
  end

  def select_wallet(i)
    self.delegate.wallet_changed(i)
    close
  end

  def close
    dismiss()
  end

  def load_table_data
    {rows: wallet_rows}
  end

  def wallet_rows
    return [] if self.wallets.nil?
    rows = []
    self.wallets.each do |wallet|
      rows << {cell_type: "custom_row_wallet", name: wallet.wallet_type.name, balance: "#{wallet.wallet_type.currency.short_name} #{wallet.balance}", color: wallet.wallet_type.color, is_default: wallet.is_default, action: "select_wallet"}
    end
    rows
  end
end
