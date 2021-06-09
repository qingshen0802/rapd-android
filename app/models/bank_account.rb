class BankAccount < BaseEntity

  attr_accessor :bank_name, :branch_number, :branch_digit,
                :account_digit, :account_number, :account_type, 
                :is_system_account, :profile_id, :user_id, :bank_name_id

end