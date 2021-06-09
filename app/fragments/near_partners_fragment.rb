class NearPartnersFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  attr_accessor :category_filter, :currency_filter

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    "Near Partners"
  end
  
  def load_views
    self.category_filter = getArguments().getString("category_filter");
    self.currency_filter = getArguments().getString("currency_filter");
    init_filter_view() unless category_filter.nil? && currency_filter.nil?
    manager = EstablishmentManager.shared_manager   
    manager.delegate = self
    manager.fetch_all
  end

  def items_fetched(profiles)
    rows = []
    profiles.each do |profile|
      rows << {cell_type: "custom_row_partner", action: "display_profile"}.merge(profile.to_cell)
    end
    adapter = NearPartnerAdapter.new(self,rows)
    outlets['near_partners_list'].adapter = adapter 
  end
  
  def nested_fragment?
    true
  end
  
  def has_actionbar?
    false
  end
  
  def init_filter_view
    second_filter = !category_filter.empty? && !currency_filter.empty?
    outlets['filter_1'].text = category_filter.empty? ? currency_filter : category_filter
    outlets['filter_2'].text = currency_filter if second_filter
    outlets['separator'].set_gone unless second_filter
  end
  
  def onClick(button)
    super(button)
  end
  
  def display_profile (establishment)
    switch_to_fragment('establishment details', with_layout: 'activity_main', container: 'main')
  end

end