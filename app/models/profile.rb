class Profile < BaseEntity

  attr_accessor :id, :type, :photo, :photo_url, :photo_mime_type, :full_name, 
                :document_id, :email, :is_legal_representer, :accepts_terms, 
                :is_legal_represented, :legal_representer_name, :legal_representer_document_id, 
                :legal_representer_email, :username, :user_id, :birth_date,
                :company_category_name, :company_category_id, :current_document_status,
                :bank_account_id, :facebook_active, :twitter_active, :google_plus_active, 
                :instagram_active, :referral_link, :push_notifications_active, :touch_id_active,
                :automatic_bonus, :discount_club_active, :discount_club_bonus_amount, 
                :discount_club_bonus_requirement, :discount_club_bonus_period,:cover_photo_url, :credits_amount, :description, :address, :phone_number,
                :latitude, :longitude

  def any_attachment?
    photo
  end
  
  def to_cell
    {name: "#{full_name}",user_name: "@#{username}",photo_top_url: "#{photo_url}",photo_url: "#{cover_photo_url}", credits_amount: "#{credits_amount}"}
  end

end
