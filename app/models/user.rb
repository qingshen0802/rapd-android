class User < BaseEntity

  attr_accessor :email, :password, :password_confirmation, :access_token, :lat, :lng, :phone_number, :sms_confirmation_code,
                :sms_confirmed_at, :facebook_id, :name,
                :facebook_token, :profile_ids, :profiles, :referral_link

  def sms_confirmed?
    !sms_confirmed_at.nil? && sms_confirmed_at != ""
  end

end