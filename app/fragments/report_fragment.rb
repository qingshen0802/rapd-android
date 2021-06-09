class ReportFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager
  attr_accessor :wallet, :wallets, :delegate, :count
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    view = fragmentOnCreateView(inflater, container, savedInstanceState)
    view
  end
  
  def load_views
    load_wallet
  end 

  def load_wallet
    if self.wallets.nil?
      wallet_manager = WalletManager.shared_manager
      wallet_manager.delegate = self
      wallet_manager.fetch_all({profile_id: app_delegate.current_profile_id}, "wallets_fetched")
    else
      wallets_fetched(@wallets)
    end
  end

  def wallets_fetched(wallets)
    self.wallets = wallets

    adapter = ReportAdapter.new(self, load_table_data[:rows])
    list_view.adapter = adapter
    list_view.onItemClickListener = self
  end

  def load_table_data
    {rows: wallet_rows}
  end

  def wallet_rows
      return [] if self.wallets.nil?
      rows = []
      self.wallets.each do |wallet|
        rows << {cell_type: "custom_row_report", report_title: wallet.wallet_type.name,
          report_text: get_string('report_desc')}
      end
      histComp = {cell_type: "custom_row_report", report_title: get_string('report_text_alt'),report_text: get_string('report_desc_alt')}
      @rows = rows << histComp
      
  end  

  def onItemClick(parent, view, position, id)
      count = @rows.length
      if(position == (count - 1))
        display_history
      else  
        display_wallet(id)
      end
  end

  def display_wallet(i)
    app_delegate.set_current_wallet(wallets[i])
    app_delegate.set_current_currency(wallets[i].wallet_type.currency)
    switch_to_fragment('report_detail', container: 'main')
  end

  def display_history
    switch_to_fragment('report_history', container: 'main')
  end

  def onClick(button)
    super button
  end

  def get_title
    get_string('reports_title')
  end
  
  def has_back_arrow?
    true
  end

  def list_view
      outlets['reports_list']
  end 
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    true
  end
end