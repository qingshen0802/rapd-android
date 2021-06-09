class EditCreditCardFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :credit_card

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "edit_cc_title"
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
    outlets["delete_button"].addTarget(self, action: "delete_card")
  end

  def delete_card
    cc_manager = CreditCardManager.shared_manager
    cc_manager.delegate = self
    cc_manager.delete_resource self.credit_card
  end

  def resource_deleted
    go_back
  end
end