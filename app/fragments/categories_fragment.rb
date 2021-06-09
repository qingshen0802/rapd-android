class CategoriesFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :referrer_fragment, :category_filter, :currency_filter, :order_filter, :type_filter
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string("#{referrer_fragment}_filter_title")
  end
  
  def load_views
    self.send("load_#{referrer_fragment}")
  end
  
  def load_partner
    create_sub_categories ("category_filter", get_array("partner_filter_categories"))
    create_title("Que aceite as carteiras:")
    create_sub_categories ("currency_filter",get_array('partner_filter_currency'))
  end
  
  def load_notification
    create_sub_categories ("type_filter", get_array("notification_filter_types"))
    create_title("Ordem")
    create_sub_categories ("order_filter",get_array("notification_filter_orders"))
  end
  
  def create_sub_categories(type, args)
    inflater = Android::View::LayoutInflater.from(getActivity())
    args.each do |category|
      view = inflater.inflate(R::Layout::Custom_row_categories, nil);
      view.findViewById(R::Id::Category_name).setText("#{category}");
      view.findViewById(R::Id::Category_wrapper).addTarget(self, action: 'sub_category_action', type, category)
      outlets['categories_container'].addView(view);
    end
  end
  def create_title(title_string)
    title = Android::Widget::TextView.new(getActivity)
    title.setTextColor get_color(Android::Graphics::Color::WHITE);
    title.setTextSize(Android::Util::TypedValue::COMPLEX_UNIT_SP,20);
    title.setTypeface(Utils.get_typeface_from_asset(getActivity(),"Roboto-Bold"))
    title.text  = "#{title_string}"
    outlets['categories_container'].addView(title);
  end
  
  def sub_category_action (type,arg)
    self.send("#{type}=",arg)
    switch_to_fragment("#{self.referrer_fragment}", container: "main", fragment_attributes: self.get_arguments )
  end
  
  def get_arguments
    case self.referrer_fragment
      when 'partner'
        {category_filter: self.category_filter, currency_filter: self.currency_filter}
      when 'notification'
        {order_filter: self.order_filter, type_filter: self.type_filter}
    end
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

end