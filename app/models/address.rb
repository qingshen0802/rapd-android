class Address < BaseEntity

  attr_accessor :name, :address_line_1, :address_line_2, :address_line_3, :borough, 
                :city, :state, :postal_code, :profile_id, :user_id, :default_address

  def short_address
    "#{address_line_1}, #{address_line_2} - #{city}/#{state}"
  end

end