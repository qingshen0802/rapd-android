class PartnerFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  attr_accessor :category_filter, :currency_filter
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    @view = fragmentOnCreateView(inflater, container, savedInstanceState,"action_bar_partners")
    init_tabs
    @view
  end
  
  def get_title
    get_string('partner_title')
  end
  
  def action_bar_filters
    switch_to_fragment("categories", container: "main", fragment_attributes: {category_filter: self.category_filter, currency_filter: self.currency_filter, referrer_fragment: 'partner'})
  end

  def load_views
    if getArguments() != nil
      self.category_filter = getArguments().getString("category_filter")
      self.currency_filter = getArguments().getString("currency_filter")
    end
    outlets['separator'].set_gone
    outlets['near_partners_filter_container'].set_gone
    init_filter_view() unless category_filter.nil? && currency_filter.nil?

    load_establishments
  end

  def init_tabs
    @red_color = getResources().getColor(R::Color::ColorPrimary)
    @gray_color = getResources().getColor(R::Color::Tab_inactive)

    @near = outlets['btn_tab_near']
    @discount = outlets['btn_tap_discount']
    @favorite = outlets['btn_tab_favorite']

    @near.setTextColor(@red_color)

    @near.setOnClickListener(self)
    @discount.setOnClickListener(self)
    @favorite.setOnClickListener(self)

    @establishment_list = @view.findViewById(R::Id::Near_partners_list)
  end

  def init_filter_view
    outlets['near_partners_filter_container'].set_visible
    second_filter = !category_filter.nil? && !currency_filter.nil?
    outlets['filter_1'].text = category_filter.empty? ? currency_filter : category_filter
    outlets['filter_2'].text = currency_filter if second_filter
    if second_filter
      outlets['separator'].set_visible
    else
      outlets['separator'].set_gone
    end
  end

  def load_establishments
    manager = EstablishmentManager.shared_manager
    manager.delegate = self
    manager.fetch_all
  end

  def items_fetched(profiles)
    @profiles = profiles
    adapter = NearPartnerAdapter.new(self,@profiles)
    @establishment_list.adapter = adapter
    @establishment_list.onItemClickListener = self
  end

  def onItemClick(parent, view, position, id)
    switch_to_fragment("partner_payment", container: 'main', fragment_attributes: {profile: @establishment_list.adapter.getItem(position)})
    # switch_to_fragment('establishment_details', with_layout: 'activity_main', container: 'main', fragment_attributes: {profile: @establishment_list.adapter.getItem(position)})
  end

  def onClick(view)
    if view == @near
      changeListType(0)
      view.setTextColor(@red_color)
      @discount.setTextColor(@gray_color)
      @favorite.setTextColor(@gray_color)
    elsif view == @discount
      changeListType(1)
      view.setTextColor(@red_color)
      @near.setTextColor(@gray_color)
      @favorite.setTextColor(@gray_color)
    elsif view == @favorite
      changeListType(2)
      view.setTextColor(@red_color)
      @near.setTextColor(@gray_color)
      @discount.setTextColor(@gray_color)
    end
  end

  def has_actionbar_menu?
    true
  end

  def changeListType(type)
    if type == 0
      adapter = NearPartnerAdapter.new(self,@profiles)
      @establishment_list.adapter = adapter
    elsif type == 1
      filtered_profiles = []
      @profiles.each do |profile|
        if profile.discount_club_bonus_amount != nil
          filtered_profiles<<profile
        end
      end
      adapter = NearPartnerAdapter.new(self,filtered_profiles)
      @establishment_list.adapter = adapter
    else
    end
  end
end