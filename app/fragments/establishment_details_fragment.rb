class EstablishmentDetailsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :profile

  def onCreateView(inflater, container, savedInstanceState)
    super
    view = fragmentOnCreateView(inflater, container, savedInstanceState)
    view
  end

  def load_views
      data = {rows: [
          {cell_type: "custom_view_pager_shop_details",photo_url: "http://brandfiercely.com/wp-content/uploads/2015/08/Pizza-Hut.jpg"},
          {cell_type: "custom_view_pager_shop_details",photo_url: "http://ddotomen.com/wp-content/uploads/walking-dead-ddotomen.jpeg"},
          {cell_type: "custom_view_pager_shop_details",photo_url: "http://images.boomsbeat.com/data/images/full/19640/game-of-thrones-season-4-jpg.jpg"}
        ]}
      adapter1 = ShopImageViewPagerAdapter.new(self);
      adapter1.setData(data[:rows])
      getActivity.set_toolbar_title("Establishment")
      outlets[:view_pager].setAdapter adapter1
      outlets['indicator'].setViewPager outlets[:view_pager]
      outlets['establishment_description'].text = profile.description
      outlets['see_on_map_button'].addTarget(self, action: 'show_map')
      outlets['borough_city'].text = ""
      outlets['street'].text = profile.address
      outlets['establishment_phone'].text = profile.phone_number

      outlets['shop_balance_layout'].set_gone if profile.discount_club_bonus_amount.nil?
      outlets['shop_promo_layout'].set_gone if profile.discount_club_bonus_amount.nil?
      outlets['shopping_club_balance'].text = "R$ #{profile.discount_club_bonus_amount}"
      outlets['make_payment_button'].addTarget(self, action: 'make_payment')
      outlets['site_tv'].addTarget(self, action: 'view_site')
  end
  
  def show_map
    uri =  "geo:0,0?q=#{profile.latitude}, #{profile.longitude}"
    intent = Android::Content::Intent.new(Android::Content::Intent::ACTION_VIEW, Android::Net::Uri.parse(uri));
    getActivity.startActivity(intent)
    #switch_to_fragment("map", with_layout: 'activity_main', container: 'main')
  end

  def make_payment
    puts "Make payment"
  end

  def view_site
    puts "View company site"
  end

  def get_title
    get_string('wallet_title')
  end
  
  def onClick(button)
      super(button)
  end  
  
  def has_drawer_toggle?
    false
  end
  
  def has_back_arrow?
    true
  end
  
  def has_actionbar_menu?
    true
  end

end