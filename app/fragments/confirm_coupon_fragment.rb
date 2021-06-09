class ConfirmCouponFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :profile, :coupon, :wallet_types, :back_destination

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def load_views
    @text_amount = outlets['text_amount']
    @text_description = outlets['text_description']

    @btn_confirm = outlets['btn_continue']
    @btn_confirm.setOnClickListener(self)

    @text_description.text = coupon.coupon_description
    load_coupon_data

    puts "#{back_destination}"
  end

  def get_title
    "Oba! Tem bônus"
  end

  def has_back_arrow?
    true
  end

  def has_drawer_toggle?
    false
  end

  def load_coupon_data
    manager = WalletTypeManager.shared_manager
    manager.delegate = self
    manager.fetch_all()
  end

  def items_fetched(wallet_types)
    self.wallet_types = wallet_types
    self.wallet_types.each { |wallet_type|
      if wallet_type.remote_id.to_s == coupon.wallet_type_id.to_s
        @text_amount.text = "#{wallet_type.currency.short_name}#{coupon.amount}"
      end
    }
  end

  def onClick(view)
    @dialog = Utils.loading_dialog getActivity
    manager = CreditCouponManager.shared_manager
    manager.delegate = self
    manager.register_coupon(coupon.remote_id.to_s, profile.remote_id.to_s)
  end

  def resource_created(coupon)
    @dialog.dismiss
    go_back_to_fragment(self.back_destination)
    # switch_to_fragment("settings", container: 'main', fragment_attributes: {profile: @profile})
  end

  def resource_creation_failed
    @dialog.dismiss
    go_back_to_fragment(self.back_destination)
    # switch_to_fragment("settings", container: 'main', fragment_attributes: {profile: @profile})
  end

end