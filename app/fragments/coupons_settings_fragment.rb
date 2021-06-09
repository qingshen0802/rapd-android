class CouponsSettingsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager

  attr_accessor :profile, :coupons, :back_destination

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def load_views
    @edt_one = outlets['edt_number_one']
    @edt_two = outlets['edt_number_two']
    @edt_three = outlets['edt_number_three']
    @edt_four = outlets['edt_number_four']
    @edt_five = outlets['edt_number_five']

    @btn_bonus = outlets['btn_bonus']
    @btn_bonus.setOnClickListener(self)
    @edt_numbers = [@edt_one, @edt_two, @edt_three, @edt_four, @edt_five]

    @edt_one.addTextChangedListener(CouponTextChangedListener.new(self, "first_text_changed"))
    @edt_two.addTextChangedListener(CouponTextChangedListener.new(self, "second_text_changed"))
    @edt_three.addTextChangedListener(CouponTextChangedListener.new(self, "third_text_changed"))
    @edt_four.addTextChangedListener(CouponTextChangedListener.new(self, "forth_text_changed"))
    @edt_five.addTextChangedListener(CouponTextChangedListener.new(self, "fifth_text_changed"))

    # @edt_one.setOnFocusChangeListener(FocusChangeListener.new(self, "text_focus_changed"))
    # @edt_two.setOnFocusChangeListener(FocusChangeListener.new(self, "text_focus_changed"))
    # @edt_three.setOnFocusChangeListener(FocusChangeListener.new(self, "text_focus_changed"))
    # @edt_four.setOnFocusChangeListener(FocusChangeListener.new(self, "text_focus_changed"))
    # @edt_five.setOnFocusChangeListener(FocusChangeListener.new(self, "text_focus_changed"))
    load_coupons

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

  def load_coupons
    manager = CreditCouponManager.shared_manager
    manager.delegate = self
    manager.fetch_all()
  end

  def items_fetched(coupons)
    self.coupons = coupons
    puts "#{coupons.count}"
  end

  def onClick(view)
    coupon_code = ""
    has_coupon = false
    if @edt_one.text_as_string != "" && @edt_two.text_as_string != "" && @edt_three.text_as_string != "" && @edt_four.text_as_string != "" && @edt_five.text_as_string != ""
      coupon_code = "#{@edt_one.text_as_string}#{@edt_two.text_as_string}#{@edt_three.text_as_string}#{@edt_four.text_as_string}#{@edt_five.text_as_string}"
    end
    self.coupons.each {|coupon|
      if coupon.coupon_code == coupon_code
        has_coupon = true
        switch_to_fragment("confirm_coupon", container: 'main', fragment_attributes: {profile: @profile, coupon: coupon, back_destination: self.back_destination})
      end
    }
    if !has_coupon
      Utils.show_dialog(getActivity, "Error", "Wrong Coupon Code.")
    end
  end

  def first_text_changed(s)
    if s != ""
      @edt_two.requestFocus
    end
  end

  def second_text_changed(s)
    if s != ""
      @edt_three.requestFocus
    else
      @edt_one.requestFocus
    end
  end

  def third_text_changed(s)
    if s != ""
      @edt_four.requestFocus
    else
      @edt_two.requestFocus
    end
  end

  def forth_text_changed(s)
    if s != ""
      @edt_five.requestFocus
    else
      @edt_three.requestFocus
    end
  end

  def fifth_text_changed(s)
    if s != ""
      @edt_five.requestFocus
    else
      @edt_four.requestFocus
    end
  end

  # def text_focus_changed(view, has_focus)
  #   puts "#{view}, #{has_focus}"
  #   index = 0
  #   @edt_numbers.each { |edt_text|
  #     if view == edt_text
  #       if has_focus
  #         return
  #       end
  #     end
  #     index+=1
  #   }
  # end

end