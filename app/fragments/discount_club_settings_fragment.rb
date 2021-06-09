class DiscountClubSettingsFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('partners_shopping')
  end
    
  def load_views
    @profile = current_profile = app_delegate.current_profile
    self.initialize_form
    outlets['discount_period'].addTarget(self,action: 'launch_calendar')
    outlets['confirmation_button'].addTarget(self,action: 'update_profile')
    outlets['toggle_activate'].setOnCheckedChangeListener self
  end
  
  def launch_calendar
    cal = Java::Util::Calendar.getInstance(Java::Util::TimeZone.getDefault())
    cal = calendar_from_days(@profile.discount_club_bonus_period) unless @profile.discount_club_bonus_period.nil?
    @datePicker = 	Android::App::DatePickerDialog.new(getActivity, self, cal.get(Java::Util::Calendar::YEAR), 
                                                       cal.get(Java::Util::Calendar::MONTH), cal.get(Java::Util::Calendar::DAY_OF_MONTH))
    @datePicker.setCancelable(false)
    @datePicker.show
  end
  
  def onDateSet(view, selectedYear, selectedMonth, selectedDay)
    month = "#{selectedMonth +1}"
    month = "0#{month}" unless month.length > 1
    outlets['discount_period'].text = "#{selectedDay}/#{month}/#{selectedYear}"
    @profile.discount_club_bonus_period = number_of_days(selectedYear, selectedMonth, selectedDay)
  end
  
  def onCheckedChanged(buttonView, isChecked)
    @profile.discount_club_active = isChecked
  end
  
  def update_profile
    @profile.discount_club_bonus_amount = outlets['bonus_input'].text.toString
    @profile.discount_club_bonus_requirement = outlets['currency_input'].text.toString
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.update_resource @profile
  end
  
  def initialize_form
    outlets['bonus_input'].text = "#{@profile.discount_club_bonus_amount}" 
    outlets['currency_input'].text = "#{@profile.discount_club_bonus_requirement}"
    outlets['toggle_activate'].setChecked  "#{@profile.discount_club_active}"
    if @profile.discount_club_bonus_period != nil
      outlets['discount_period'].text = "#{calendar_date_string(calendar_from_days(@profile.discount_club_bonus_period))}"
    end
  end
  
  def resource_updated (profile)
    app_delegate.send("set_#{profile.type.downcase}_profile",profile)
  end
  
  def number_of_days (selectedYear,selectedMonth,selectedDay)
    calendar = Java::Util::Calendar.getInstance();
    calendar.set(Java::Util::Calendar::YEAR, selectedYear);
    calendar.set(Java::Util::Calendar::MONTH, selectedMonth)
    calendar.set(Java::Util::Calendar::DAY_OF_MONTH, selectedDay);
    Java::Util::Concurrent::TimeUnit::MILLISECONDS.toDays(calendar.getTimeInMillis()- Java::Util::Calendar.getInstance().getTimeInMillis())
  end
  
  def calendar_from_days(num)
    cal = Java::Util::Calendar.getInstance();
    cal.add(Java::Util::Calendar::MILLISECOND, (num * 24 * 3600 * 1000));
    cal
  end
  
  def calendar_date_string(cal)
    month = "#{cal.get(Java::Util::Calendar::MONTH) +1}"
    month = "0#{month}" unless month.length > 1
    "#{cal.get(Java::Util::Calendar::DAY_OF_MONTH)}/#{month}/#{cal.get(Java::Util::Calendar::YEAR)}"
  end

  def has_drawer_toggle?
    false
  end

  def has_back_arrow?
    true
  end

  
  def onClick(button)
    super(button)
  end
  
end