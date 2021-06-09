class AppDelegate
  @@delegate = ""
  
  def self.shared_delegate
    @@delegate.is_a?(AppDelegate) ? @@delegate : new
  end
  
  def base_url
    "https://trat.to"
  end
  
  def access_token
    current_user.access_token
  end
  
  def api_access_token
    "YOUR_API_TOKEN"
  end
  
  def current_user
    Store['current_user'].nil? ? nil : User.new(Store['current_user'])
  end
  
  def set_user(user)
    Store['current_user'] = user.to_json
  end
  
  def set_current_profile(profile)
    set_person_profile(profile)
    set_current_profile_id(profile.remote_id)
  end
  
  def current_profile
    return company_profile if has_company_profile? && current_profile_id.to_i == company_profile.remote_id.to_i
    person_profile
  end
  
  def update_current_profile(profile)
    set_company_profile(profile) if has_company_profile? && current_profile_id.to_i == company_profile.remote_id.to_i
    set_person_profile(profile)
  end
  
  def secondary_profile
    return nil unless has_company_profile?
    return person_profile if current_profile_id.to_i == company_profile.remote_id.to_i
    company_profile
  end
  
  def set_person_profile(profile)
    Store['person_profile'] = profile.to_json
  end

  def person_profile
    Store['person_profile'].nil? ? nil : Profile.new(Store['person_profile'])
  end

  
  def set_company_profile(profile)
    Store['company_profile'] = profile.to_json
  end
  
  def company_profile
    Store['company_profile'].nil? ? nil : Profile.new(Store['company_profile'])
  end
  
  def has_company_profile?
    !Store['company_profile'].nil?
  end
  
  def set_current_company_profile(profile)
    Store['current_company_profile'] = profile.to_json
  end
  
  def current_company_profile
    Store['current_company_profile'].nil? ? nil : Profile.new(Store['current_company_profile'])
  end
  
  def set_profile_ids(profile_ids)
    Store['profile_ids'] = profile_ids
  end
  
  def profile_ids
    Store['profile_ids'].nil? ? nil : Store['profile_ids']
  end

  def set_default_wallet(wallet)
    Store['default_wallet'] = wallet
  end

  def default_wallet
    Store['default_wallet'].nil? ? nil : Wallet.new(Store["default_wallet"])
  end

  def set_current_wallet(wallet)
    Store['current_wallet'] = wallet.to_json
  end

  def current_wallet
    Store['current_wallet'].nil? ? nil : Wallet.new(Store["current_wallet"])
  end

  def set_current_currency(currency)
    Store['current_currency'] = currency.to_json
  end

  def current_currency
    Store['current_currency'].nil? ? nil : Currency.new(Store["current_currency"])
  end
  
  # User authentication
  def logged_in?
    !current_user.nil?
  end
  
  def current_profile_id
    Store['current_profile_id'] || profile_ids.first
  end
  
  def set_current_profile_id(profile_id)
    Store['current_profile_id'] = profile_id
  end
  
  def empty_for_logout()
    Store['current_user'] = nil;
    Store['profile_ids'] = nil;
  end

end