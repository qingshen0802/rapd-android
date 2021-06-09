class EditProfileFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :is_updating_date_of_birth
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    outlets['full_name'].text = @profile.full_name
    outlets['email_address'].text = @profile.email
    outlets['user_cpf'].text = @profile.document_id
    if @profile.type == "Person"
      outlets['cpf_text'].text = R::String::Cpf
      outlets['user_birth_date'].text = @profile.birth_date
      outlets['user_birth_date'].addTextChangedListener(TextChangedListener.new(self, "date_mask"))
    else
      outlets['cpf_text'].text = R::String::Cnpj
          outlets['birth_date_text'].setVisibility(Android::View::View::INVISIBLE)
      outlets['user_birth_date'].setVisibility(Android::View::View::INVISIBLE)
    end
    outlets['save_button'].addTarget(self, action: 'save')

  end

  # def launch_calendar
  #   cal = Java::Util::Calendar.getInstance(Java::Util::TimeZone.getDefault())
  #   cal = calendar_from_days(@profile.discount_club_bonus_period) unless @profile.discount_club_bonus_period.nil?
  #   @datePicker = 	Android::App::DatePickerDialog.new(getActivity, self, cal.get(Java::Util::Calendar::YEAR),
  #                                                     cal.get(Java::Util::Calendar::MONTH), cal.get(Java::Util::Calendar::DAY_OF_MONTH))
  #   @datePicker.setCancelable(false)
  #   @datePicker.show
  # end
  #
  # def onDateSet(view, selectedYear, selectedMonth, selectedDay)
  #   month = "#{selectedMonth +1}"
  #   month = "0#{month}" unless month.length > 1
  #   outlets['discount_period'].text = "#{selectedDay}/#{month}/#{selectedYear}"
  #   @profile.discount_club_bonus_period = number_of_days(selectedYear, selectedMonth, selectedDay)
  # end

  def get_title
    "Meus dados pessoais"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def onClick(button)
    super button
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end
  
  def save
    self.profile.full_name = self.outlets["full_name"].text.toString
    self.profile.email = self.outlets["email_address"].text.toString
    self.profile.birth_date = self.outlets["user_birth_date"].text.toString
    # self.profile.company_category_name = self.outlets["category_select"].text.toString
    
    @dialog = Utils.loading_dialog(getActivity)
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.update_resource(self.profile)
  end
  
  def resource_updated(profile)
    # self.profile_controller.load_profile
    # self.profiles_controller.load_profiles
    
    @dialog.dismiss
    getFragmentManager().popBackStack()
  end
  
  def date_mask
    if self.is_updating_date_of_birth
      self.is_updating_date_of_birth = false
      return
    end
    
    self.is_updating_date_of_birth = true
    
    str = outlets["user_birth_date"].text.toString
    
    str = str.gsub("/", "") if str =~ /\//
    
    if str.length > 4
      day = str[0, 2]
      month = str[2, 2]
      year = str[4..-1]
      str = day + "/" + month + "/" + year
    elsif str.length > 2
      day = str[0, 2]
      month = str[2..-1]
      str = day + "/" + month
    end
    
    outlets["user_birth_date"].text = str
    outlets["user_birth_date"].setSelection(outlets["user_birth_date"].text.toString.length)
  end
  
end
