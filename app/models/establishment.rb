class Establishment < BaseEntity

  attr_accessor :id, :name, :address, :state, :city, :country, :phone_number, :description, :latitude, :longitude,
                :distance,:photo_url, :photo_top_url, :link, :user_id, :user, :user_discount_amount, :current_discount_id,
                :current_discount, :zip_code,:user_name

end