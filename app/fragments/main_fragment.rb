class MainFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :wallet, :wallets, :rapdTransaction, :transactionValues, :period, :profiles, :list_type

  def onCreateView(inflater, container, savedInstanceState)
    super

    @view = fragmentOnCreateView(inflater, container, savedInstanceState)
    dropDownMenu
    init_tabs
    self.list_type = 0
    @view
  end

  def load_views
    outlets['swipeContainer'].setOnRefreshListener self
    load_wallets
    load_profiles
    findGraph.setNoDataText("No Transactions From This Period".to_java)
  end

  def load_wallets
    wallet_manager = WalletManager.shared_manager
    wallet_manager.delegate = self
    wallet_manager.fetch_all({profile_id: app_delegate.current_profile_id}, "wallets_fetched")
  end

  def wallets_fetched(wallets)
    self.wallets = wallets
    set_wallet(app_delegate.default_wallet)
    load_rapd_transactions('this_year')
  end

  def onRefresh()
    outlets['swipeContainer'].setRefreshing(false)
    load_rapd_transactions(self.period)
  end

  def load_rapd_transactions(period_type)
    if @dialog == nil
      @dialog = Utils.loading_dialog getActivity
    else
      @dialog.show
    end

    self.period = period_type
    rt_manager = RapdTransactionManager.shared_manager
    rt_manager.delegate = self
    wallet_remote_id = self.wallet.nil? ? nil : self.wallet.remote_id
    rt_manager.fetch_all({page: 1, wallet_id: wallet_remote_id, period_type: period_type}, "rapd_transactions_fetched")
  end

  def rapd_transactions_fetched(rapd_transactions)
    @dialog.dismiss
    transactionValues = []
    @rt_objects = []
    rapd_transactions.each { |object|
      if self.list_type == 1
        if object.amount < 0
          @rt_objects << object
        end
      elsif self.list_type == 2
        if object.amount >= 0
          @rt_objects << object
        end
      else
        @rt_objects << object
      end
    }
    @rt_objects.reverse.each_with_index do |transactionValue,index|
      transactionValues << newEntry(index,"#{transactionValue.amount}")
    end
    latestRegisters(@rt_objects)
    return if rapd_transactions.size == 0
    refresh_graph(transactionValues)
    outlets['swipeContainer'].setRefreshing(false)
  end

  def load_profiles
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.fetch_all({}, "profile_fetched")
  end

  def profile_fetched(profiles)
    self.profiles = profiles
  end

  def action_bar_wallets
    dialog = ChooseWalletFragment.new_instance(self, self.wallets)
    dialog.show(getActivity().getSupportFragmentManager(), "choose_wallet_dialog")
  end

  def wallet_changed(i)
    set_wallet(wallets[i])
    load_rapd_transactions(self.period)
  end

  def set_wallet(wallet)
    self.wallet = wallet
    outlets["receipt_amount"].text = "#{self.wallet.wallet_type.currency.short_name} #{self.wallet.balance}"
  end


  def dropDownMenu
    menu = [("7 dias").to_java,
            ("15 dias").to_java,
            ("30 dias").to_java,
            ("6 meses").to_java,
            ("#{year}").to_java]
    adapter = SpinnerAdapter.new(getActivity, menu)
    outlets['spinner_wallet'].setAdapter(adapter)
    outlets['spinner_wallet'].setOnItemSelectedListener(self)
    outlets['spinner_wallet'].setSelection(4)
  end

  def onItemSelected(parent, view, position, id)
    return if self.wallet.nil?
    case position
      when 0
        load_rapd_transactions(7)
      when 1
        load_rapd_transactions(15)
      when 2
        load_rapd_transactions(30)
      when 3
        load_rapd_transactions(180)
      when 4
        load_rapd_transactions('this_year')
    end
    findGraph.clear()
  end

  def onNothingSelected(parent)
  end

  def changeListType(list_type)
    self.list_type = list_type
    load_rapd_transactions(self.period)
  end

  def latestRegisters(balanceList)
    @latestRegistersListView = @view.findViewById(R::Id::Latest_registers_list_view)
    adapter = LatestRegistersAdapter.new(getActivity, balanceList, self.list_type, self.wallet)
    @latestRegistersListView.adapter = adapter
    @latestRegistersListView.onItemClickListener = self
  end

  def onItemClick(parent, view, position, id)
    switch_to_fragment('receipt', container: 'main', fragment_attributes: {referrer_fragment: 'receipt_detail', rt_detail: @rt_objects[position], wallet: self.wallet})
  end

  def refresh_graph(balanceList)
    dataSet = lineDataSet.new(balanceList, "")
    # value_formatter = ValueFormatter.new(self.wallet.wallet_type.currency.short_name)
    axis_formatter = AxisFormatter.new(self.wallet.wallet_type.currency.short_name)

    dataSet.setDrawFilled(true)
    dataSet.setMode(cubic_bezier)
    white =  Android::Graphics::Color::WHITE
    black =  Android::Graphics::Color::BLACK
    gray = Android::Graphics::Color::GRAY
    red = Android::Graphics::Color.parseColor("#F15E4F")
    transparent = Android::R::Color::Transparent
    dataSet.setColor(red)
    # dataSet.setValueTextColor(black)
    # dataSet.setCircleColor(white)
    # dataSet.setCircleRadius(5)
    dataSet.setFillColor(red)
    dataSet.setFillAlpha(255)
    # dataSet.setCircleColorHole(red)
    dataSet.setDrawValues(false)

    dataSet.setHighLightColor(red)
    dataSet.setHighlightEnabled(true)
    dataSet.setDrawHighlightIndicators(true)
    # dataSet.setValueFormatter(value_formatter)
    findGraph.onChartValueSelectedListener = self

    lineDataOutput = lineData.new([dataSet])
    lineDataOutput.setValueTextColor(gray)
    lineDataOutput.setValueTextSize(10)

    findGraph.data = lineDataOutput

    findGraph.animateXY(1000, 1000)
    findGraph.setGridBackgroundColor(red)
    findGraph.getAxisRight.setEnabled(false)
    findGraph.getAxisLeft.setEnabled(true)
    findGraph.setBorderColor black
    findGraph.getLegend.setEnabled(false)
    findGraph.getDescription().setEnabled(false)
    findGraph.setTouchEnabled(true)
    findGraph.setDrawMarkerViews(true)

    y_axis = findGraph.getAxisLeft
    y_axis.setGridColor(white)
    y_axis.setTextColor(black)
    y_axis.setDrawAxisLine(true)
    y_axis.setLabelCount(4)
    y_axis.setDrawZeroLine(true)
    y_axis.setDrawGridLines(false)
    y_axis.setValueFormatter(axis_formatter)

    x_axis = findGraph.getXAxis
    x_axis.setTextColor(gray)
    x_axis.setTextSize(14)
    x_axis.setDrawLabels(false)
    x_axis.setDrawAxisLine(false)
    x_axis.setGridColor(gray)
    x_axis.setDrawGridLines(false)
    x_axis.setEnabled(true)
    x_axis.setLabelCount(7, false)
    findGraph.invalidate
  end

  def findGraph
    outlets['graph']
  end

  def onValueSelected(entry, highlight)
    findGraph.centerViewToAnimated(entry.getX(), entry.getY(), findGraph.getData().getDataSetByIndex(highlight.getDataSetIndex()).getAxisDependency(), 500)
  end

  def onNothingSelected()
  end

  def newEntry(x, y)
    Com::Github::Mikephil::Charting::Data::Entry.new(x,y.to_f)
  end

  def lineDataSet
    Com::Github::Mikephil::Charting::Data::LineDataSet
  end

  def lineData
    Com::Github::Mikephil::Charting::Data::LineData
  end

  def cubic_bezier
    Com::Github::Mikephil::Charting::Data::LineDataSet::Mode::CUBIC_BEZIER
  end

  def newTransaction(location, amount)
    RapdTransaction.new(location: location, amount: amount)
  end

  def get_title
    get_string('wallet_title')
  end

  def onClick(view)
    red = Android::Graphics::Color.parseColor("#F15E4F")
    black = Android::Graphics::Color::BLACK
    if view == @todo
      changeListType(0)
      view.setTextColor(red)
      @payments.setTextColor(black)
      @receipts.setTextColor(black)
    elsif view == @payments
      changeListType(1)
      view.setTextColor(red)
      @todo.setTextColor(black)
      @receipts.setTextColor(black)
    else
      changeListType(2)
      view.setTextColor(red)
      @todo.setTextColor(black)
      @payments.setTextColor(black)
    end
  end

  def has_actionbar_menu?

    true
  end

  def create_date_with_format(date, format='MM/dd/yyyy')
    simple_format = Java::Text::SimpleDateFormat.new(format)
    simple_format.format(date)
  end

  def days_ago (num)
    cal = Java::Util::GregorianCalendar.new
    cal.add(Java::Util::Calendar::DAY_OF_MONTH, -(num))
    cal.getTime()
  end

  def months_ago (num)
    cal = Java::Util::GregorianCalendar.new
    cal.add(Java::Util::Calendar::MONTH, -(num))
    cal.getTime()
  end

  def year
    Java::Util::Calendar.getInstance.get(Java::Util::Calendar::YEAR)
  end

  def init_tabs
    @todo = @view.findViewById(R::Id::Main_your_balance)
    @payments = @view.findViewById(R::Id::Main_payments)
    @receipts = @view.findViewById(R::Id::Main_receipts)
    red = Android::Graphics::Color.parseColor("#F15E4F")
    @todo.setTextColor(red)
    @todo.setOnClickListener(self)
    @payments.setOnClickListener(self)
    @receipts.setOnClickListener(self)
  end
end
