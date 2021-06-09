class ReportDetailFragment < Android::Support::V4::App::Fragment 
  include BaseView
  include FragmentManager
  attr_accessor :wallets, :rapdTransaction, :transactionValues, :transactions, :period, :yearly_report

  def onCreateView(inflater, container, savedInstanceState)
  super
      view = fragmentOnCreateView(inflater, container, savedInstanceState)
      view
  end

  def load_views
      set_up_list
      findGraph.setNoDataText(get_string('reports_title'))
  end

  def set_up_list
      @dialog = Utils.loading_dialog getActivity
      adapter = ReportManager.shared_manager

      adapter.delegate = self
      adapter.type = "yearly"
      adapter.fetch(app_delegate.current_wallet.remote_id, year: 'this_year')
  end    

  def item_fetched(report)
      @dialog.dismiss
      self.yearly_report = report
      months = report.months
      if months.first['balance'] >=0
        outlets['amount_month'].text = "#{app_delegate.current_currency.short_name}#{Utils.format_money(months.first['balance'])}"
      else
        outlets['amount_month'].text = "-#{app_delegate.current_currency.short_name}#{Utils.format_money(months.first['balance'].abs)}"
      end

      outlets['amount_period'].text = "#{report.rapd_transactions.size}"

      reportValues = []
      return if months.size == 0 
      months.each_with_index do |month, index|
        reportValues << newEntry(index, "#{month['balance']}")
      end

      adapter = StatementAdapter.new(self, load_table_data[:rows])
      list_view.adapter = adapter

      refresh_graph(reportValues)  
  end

  def load_table_data
      {rows: month_rows}
  end

  def month_rows
      @month = self.yearly_report.months
      return [] if self.yearly_report.nil?
      rows = []
      @month.each do |month|
        rows << {cell_type: "custom_row_statement_report", month_name: locale("#{month['month']}").capitalize, action: "month_report", action_param: month}
      end
      @rows = rows
  end 

  def month_report(month)
     switch_to_fragment('report_month', container: "main", fragment_attributes: {month: @month[month]})
  end

  def refresh_graph(reportList)
        dataSet = lineDataSet.new(reportList,"")
        dataSet.setDrawFilled(true)
        white =  Android::Graphics::Color::WHITE
        gray = Android::Graphics::Color::GRAY
        red = Android::Graphics::Color.parseColor("#F15E4F")
        transparent = Android::R::Color::Transparent

        dataSet.setColor(white)
        dataSet.setFillColor(red)
        dataSet.setFillAlpha(255)
        dataSet.setLineWidth(4)
        dataSet.setHighlightEnabled(false)
        dataSet.setValueTextColor(transparent)
        dataSet.setDrawCircles(false)
        
        lineDataOutput = lineData.new([dataSet])
        lineDataOutput.setValueTextColor(transparent)
        lineDataOutput.setValueTextSize(10)

        findGraph.setBackgroundColor(transparent)
        findGraph.setExtraBottomOffset(30.0)
        findGraph.setViewPortOffsets(50.0, 0.0, 50.0, 70.0)
        findGraph.data = lineDataOutput
        findGraph.animateXY(1000, 1000)
        findGraph.setPinchZoom(false)
        findGraph.setBorderColor(white)
        findGraph.setGridBackgroundColor(transparent)
        findGraph.getAxisRight.setEnabled(false)
        findGraph.getAxisLeft.setEnabled(false)
        findGraph.getLegend.setEnabled(false)
        findGraph.getDescription().setEnabled(false)
        findGraph.setTouchEnabled(false)
          
        x_axis = findGraph.getXAxis
        x_axis.setValueFormatter(MonthFormatter.new())
        x_axis.setPosition(axis_bottom) 
        x_axis.setGridColor(transparent)   
        x_axis.setTextColor(gray)
        x_axis.setTextSize(12)
        x_axis.setDrawLabels(true)
        x_axis.setDrawAxisLine(false)
        x_axis.setDrawGridLines(false)
        x_axis.setEnabled(true)
        x_axis.setLabelCount(12, true)
        findGraph.invalidate      
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

  def axis_bottom
      Com::Github::Mikephil::Charting::Components::XAxis::XAxisPosition::BOTTOM
  end 

  def locale(date)
      usa = Java::Text::SimpleDateFormat.new("yyyy-MM", Java::Util::Locale::US)
      formattedDateUSA = usa.parse(date)
      brazil = Java::Util::Locale.new("pt", "BR")
      dateFormat = Java::Text::SimpleDateFormat.new("MMMM", brazil) 
      formattedDate = dateFormat.format(formattedDateUSA)
      formattedDate
  end 

  def list_view
      outlets['report_monthly_statement_list']
  end 

  def findGraph
      outlets['report_detail_graph']
  end                                       

  def get_title
      get_string('reports_title')
  end
  
  def onClick(button)
      super(button)
  end

  def has_back_arrow?
      true
  end  
  
  def has_actionbar_menu?
      false
  end
end
