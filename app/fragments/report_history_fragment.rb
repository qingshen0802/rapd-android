class ReportHistoryFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager
  attr_accessor :wallet, :wallets, :wallet_id, :rapdTransaction, :transactionValues, :transactions, :period, :yearly_report, :monthly_report, :year, :month, :name

  def onCreateView(inflater, container, savedInstanceState)
    super
    view = fragmentOnCreateView(inflater, container, savedInstanceState, "action_bar_report_history_menu")
    view
  end

  def load_views
  end

  def action_bar_report
  end

  def get_title
    get_string('report_history_title')
  end

  def onClick(button)
    super(button)
  end

  def has_back_arrow?
    true
  end

  def on_toolbar_back_pressed
    go_back
    true
  end

  def has_actionbar_menu?
    true
  end
end

