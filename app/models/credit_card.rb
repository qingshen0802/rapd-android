class CreditCard < BaseEntity

  attr_accessor :address_id, :profile_id, :card_type_id, :name_on_card, :card_hash,
                :last_four_digits, :user_id, :is_default_card, :make_default, 
                :remove_default, :number, :cvv, :expiry_date

  def autodetect_type
    result = 5
    
    if number =~ /^5[1-5]/
      result = 2
    elsif number =~ /^4/
      result = 1
    elsif number =~ /^3[47]/
      result = 3
    end
    
    self.card_type_id = result
  end

end