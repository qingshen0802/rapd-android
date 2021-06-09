class BankConfigFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :bank_account ,:bank_account_ids
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    view = fragmentOnCreateView(inflater, container, savedInstanceState)
    view
  end
  
  def load_views
    @bank = BankAccount.new 
    load_bank_accounts
    account_selector
    self.outlets['save_button_bank_config'].addTarget(self, action: 'create_bank_account')
  end

  def create_bank_account
    if(self.outlets['branch_ET'].text.toString.length != 0  &&
       self.outlets['branch_digit_ET'].text.toString.length != 0 &&
       self.outlets['account_ET'].text.toString.length != 0 &&
       self.outlets['account_digit_ET'].text.toString.length != 00 && 
       @bank.account_type != "Selecione".to_java  && 
       @bank.bank_name != "Selecione".to_java )

      @bank.branch_number = self.outlets['branch_ET'].text.toString
      @bank.branch_digit = self.outlets['branch_digit_ET'].text.toString
      @bank.account_number = self.outlets['account_ET'].text.toString
      @bank.account_digit = self.outlets['account_digit_ET'].text.toString
      @bank.profile_id =  app_delegate.current_profile_id

      manager = BankAccountManager.shared_manager
      manager.delegate = self
      manager.create_resource(@bank)
    else 
      dialog = Utils.show_dialog(getActivity, get_string('error'), get_string('bank_config_error_dialog'))
      dialog.setCancelable(true)
    end 
  end  

  def resource_created(resource)
    go_back
  end 

  def bank_selector(names)
    if(names == [])
      names =[get_string('bank_config_option_select'),
              get_string('bank_config_option_one'),
              get_string('bank_config_option_two'),
              get_string('bank_config_option_three')]
    elsif(names != [])  
    end 
    @names = names   
    adapter = SpinnerAdapter.new(getActivity, names)
    self.outlets['bank_name_spinner'].setAdapter(adapter) 
    self.outlets['bank_name_spinner'].setOnItemSelectedListener(self)  
  end 

  def account_selector
    @menu = [get_string('bank_config_option_select'),
             get_string('bank_config_option_checking'),
             get_string('bank_config_option_savings')]      
    adapter = SpinnerAdapter.new(getActivity, @menu)
    self.outlets['bank_account_type_spinner'].setAdapter(adapter)
    self.outlets['bank_account_type_spinner'].setOnItemSelectedListener(self)    
  end 

  def load_bank_accounts
    bank_account_manager = BankNameManager.shared_manager
    bank_account_manager.delegate = self
    bank_account_manager.fetch_all({}, "items_fetched")
  end

  def items_fetched(bank_accounts)
    if(bank_accounts != [])
      self.bank_account_ids = []
      banksString = []
      bank_accounts.each do |bank_account|
      x = bank_account.name
      id = bank_account.id
      banksString << x
      self.bank_account_ids << id
      end    
      bank_selector(banksString)
    else 
      names = []
      bank_selector(names)
    end  
  end

  def onItemSelected(adapterView, view, i, l) 
    if(adapterView.getId() == self.outlets['bank_name_spinner'].getId()) 
      --i
      @bank.bank_name = @names.get(i)
      @bank.bank_name_id = self.bank_account_ids[i]
    elsif(adapterView.getId() == self.outlets['bank_account_type_spinner'].getId()) 
      @bank.account_type = @menu.get(i)
    end   
  end  

  def onNothingSelected(adapterView) 
  end 

  def get_title
    get_string('bank_config_title')
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
  
end