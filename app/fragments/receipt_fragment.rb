class ReceiptFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :referrer_fragment, :rt_detail, :wallet

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState) 
  end

  def get_title
      get_string('receipt_bar_title')
  end

  def load_views
    self.outlets['receipt_type_image'].addTarget(self, action: "receipt_details")
    self.outlets['receipt_tip_arrow'].addTarget(self, action: "tip_details")
    setProgressVisibility(false)
    business_side
    self.send("load_#{referrer_fragment}")
  end

  def business_side
    self.outlets['receipt_value_text'].text = get_string('receipt_value_business_text')
    outlets['receipt_date'].text = self.rt_detail.created_at.to_s
    outlets['receipt_value'].text = "#{self.wallet.wallet_type.currency.short_name} #{self.rt_detail.amount.abs.to_s}"
    outlets['receipt_authorization'].text = "#{self.rt_detail.id}"
    if self.rt_detail.rapd_transaction_type == "transaction_request"
      if self.rt_detail.amount >= 0
        outlets['receipt_tip_value'].text = "#pagamento"
      else
        outlets['receipt_tip_value'].text = "#recebimento"
      end
    elsif self.rt_detail.rapd_transaction_type == "refund_request"
      outlets['receipt_tip_value'].text = "#estorno"
    elsif self.rt_detail.rapd_transaction_type == "withdrawal_request"
      outlets['receipt_tip_value'].text = "#resgate"
    else
      outlets['receipt_tip_value'].text = "#deposito"
    end
    # self.outlets['receipt_type_image'].addTarget(self, action: "receipt_details")
  end

  def receipt_details
    # switch_to_fragment('welcome', container: 'welcome')
  end

  def tip_details
    # switch_to_fragment('welcome', container: 'welcome')
  end

  def setProgressVisibility(visible)
    self.outlets['receipt_loading'].setVisibility(visible ? Android::View::View::VISIBLE : Android::View::View::INVISIBLE)
  end

  def onClick(button)
    super(button)
  end
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end 
    true
  end
#   Updated Functions
  def load_receipt_detail
    if self.rt_detail.amount >= 0

      outlets['receipt_type_image'].setImageResource(R::Drawable::Arrow_in)
      outlets['receipt_user_name'].text = self.rt_detail.from_profile['full_name']
      insert_photo_for_circle_view(getActivity, photo: self.rt_detail.from_profile['photo_url'], image_view: outlets['store_image'])
      if self.rt_detail.from_profile['type'] != "Person"
        outlets['receipt_street'].text = self.rt_detail.from_profile['address']
      else
        outlets['receipt_location_text'].setVisibility(Android::View::View::GONE)
        outlets['receipt_street'].setVisibility(Android::View::View::GONE)
      end
    else
      outlets['receipt_type_image'].setImageResource(R::Drawable::Arrow_out)
      outlets['receipt_user_name'].text = self.rt_detail.to_profile['full_name']
      insert_photo_for_circle_view(getActivity, photo: self.rt_detail.to_profile['photo_url'], image_view: outlets['store_image'])
      if self.rt_detail.to_profile['type'] != "Person"
        outlets['receipt_street'].text = self.rt_detail.to_profile['address']
      else
        outlets['receipt_location_text'].setVisibility(Android::View::View::GONE)
        outlets['receipt_street'].setVisibility(Android::View::View::GONE)
      end
    end
  end
  def insert_photo_for_circle_view(activity, options = {})
    Com::Squareup::Picasso::Picasso.with(activity.getBaseContext()).load(options[:photo]).into(options[:image_view]).noFade
  end
end

