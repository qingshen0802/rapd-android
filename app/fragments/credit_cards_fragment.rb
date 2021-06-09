class CreditCardsFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :transaction, :credit_cards, :profile

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "credit_cards_title"
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def onClick(view)
    super view
  end

  def load_views
    load_credit_cards
    @adapter = CreditCardAdapter.new(self, [])
    outlets["my_cards_list_view"].adapter = @adapter
    outlets["add_new_card"].addTarget(self, action: "add_card")
    outlets["deadlines_and_fees"].addTarget(self, action: "deadlines_and_fees")
  end

  def add_card
    switch_to_fragment("add_credit_card", container: "main", fragment_attributes: {profile: profile})
  end

  def edit_card(i)
    switch_to_fragment("edit_credit_card", container: "main", fragment_attributes: {credit_card: self.credit_cards[i]})
  end

  def deadlines_and_fees
    switch_to_fragment("deadlines_and_fees", container: "main")
  end

  def choose_card_for_transaction(i)
    if !self.transaction.nil?
      self.transaction.credit_card_id = self.credit_cards[i].remote_id
      update_transaction
    end
  end

  def set_card_as_default(i)
    if !self.credit_cards[i].is_default_card
      self.credit_cards[i].make_default = true
    else
      self.credit_cards[i].remove_default = true
    end
    update_card self.credit_cards[i]
  end

  def update_card(card)
    cc_manager = CreditCardManager.shared_manager
    cc_manager.delegate = self
    cc_manager.update_resource card
  end

  def update_transaction
    self.transaction.should_charge = "1"
    transaction_manager = TransactionManager.shared_manager
    transaction_manager.delegate = self
    transaction_manager.update_resource self.transaction
  end

  def resource_updated(resource)
    if resource.is_a? CreditCard 
      load_credit_cards
    elsif resource.is_a? Transaction
      if resource.approved?
        switch_to_fragment("transaction_request_complete", container: "main", fragment_attributes: {success: resource.approved?, back_destination: "profile"})
      else
        switch_to_fragment("transaction_request_complete", container: "main", fragment_attributes: {success: resource.approved?})
      end
    end
        
  end

  def load_credit_cards
    cc_manager = CreditCardManager.shared_manager
    cc_manager.delegate = self
    cc_manager.fetch_all({profile_id: app_delegate.current_profile_id}, "cards_fetched")
  end

  def cards_fetched(cards)
    self.credit_cards = cards
    @adapter.update_objects credit_card_rows
  end

  def credit_card_rows
    self.credit_cards.map{|cc|
      {
        cell_type: "custom_row_credit_card",
        card_type_id: cc.card_type_id,
        name_on_card: cc.name_on_card,
        last_four_digits: cc.last_four_digits, 
        expiry_date: cc.expiry_date,
        is_default_card: cc.is_default_card
      }
    }
  end

end