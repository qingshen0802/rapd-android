class ReportMonthFragment < Android::Support::V4::App::Fragment
    include BaseView
    include FragmentManager
    attr_accessor :wallet, :wallets, :wallet_id, :rapdTransaction, :transactionValues, :transactions, :period, :yearly_report, :monthly_report, :year, :month, :name 

    def onCreateView(inflater, container, savedInstanceState)
        super
        view = fragmentOnCreateView(inflater, container, savedInstanceState, "action_bar_report_month_menu")
        view
    end

    def load_views
        set_up_list
    end

    def set_up_list
        @dialog = Utils.loading_dialog getActivity
        adapter = ReportManager.shared_manager
        adapter.delegate = self
        adapter.type = "monthly"
        adapter.fetch(app_delegate.current_wallet.remote_id,
                      month: month['month'].split('-')[1], 
                      year: month['month'].split('-')[0])
    end

    def item_fetched(report)
        @dialog.dismiss
        self.monthly_report = report 
        if report.transactions.size == 0
           outlets['no_transactions_value'].text =
                    get_string('no_data')
           outlets['month_total_value'].text = 
                    "#{app_delegate.current_currency.short_name} #{Utils.format_money(0)}"
           outlets['month_transactions_value'].text = 
                    get_string('no_value')
           return
        else
            if report.transactions.last['amount'] >=0
                outlets['month_total_value'].text = "#{app_delegate.current_currency.short_name}#{Utils.format_money(report.transactions.last['amount'])}"
            else
                outlets['month_total_value'].text = "-#{app_delegate.current_currency.short_name}#{Utils.format_money(report.transactions.last['amount'].abs)}"
            end
            outlets['month_transactions_value'].text = "#{report.transactions.size}"
            transaction_rows
            adapter = MonthReportAdapter.new(self, @rows)
            list_view.adapter = adapter
        end 
    end

    def transaction_rows
        @month = self.monthly_report.transactions
        @total_amount = 0
        rows = []
        sorted_transactions = @month.group_by do |month| 
            @formattedDate = month['created_at'][0..9]
            "#{locale(@formattedDate).capitalize} #{@formattedDate.split('-')[1]}/#{@formattedDate.split('-')[2]}"
        end
        sorted_transactions.map do |key,value|
            rows << {cell_type: "custom_row_charge_date", 
                      date_text: key }
            value.each do |group|
                rows << {cell_type: "custom_row_charge_credit", 
                 user_nick: "#{group['to_profile']['username']}",
                 transaction_type:"#{group['transactionable_type']}",
                 amount: group['amount'],
                 photo_url: "#{group['to_profile']['photo_url']}",
                 action: "month_report", action_param: group}
                @total_amount += group['amount']
            end
        end 
        @rows = rows
        if @total_amount >=0
            outlets['month_total_value'].text = "#{app_delegate.current_currency.short_name}#{Utils.format_money(@total_amount)}"
        else
            outlets['month_total_value'].text = "-#{app_delegate.current_currency.short_name}#{Utils.format_money(@total_amount.abs)}"
        end
    end

    def month_report(month)
        # switch_to_fragment('report_detail', container: "main", fragment_attributes: {month: @month[month]})
    end     

    def locale(date)
        usa = Java::Text::SimpleDateFormat.new("yyyy-MM", Java::Util::Locale::US)
        formattedDateUSA = usa.parse(date)
        brazil = Java::Util::Locale.new("pt", "BR")
        dateFormat = Java::Text::SimpleDateFormat.new("E", brazil) 
        formattedDate = dateFormat.format(formattedDateUSA)
        formattedDate
    end

    def action_bar_report
        # switch_to_fragment("report_detail", container: "main")
    end     

    def list_view
        outlets['ref_day_list']
    end

    def get_title
        month_format(month['month']).capitalize
    end

    def onClick(button)
        super(button)
    end

    def has_back_arrow?
        true
    end

    def on_toolbar_back_pressed
      go_back
        # switch_to_fragment("report_detail", container: "main")
        true
    end

    def month_format(date)
        usa = Java::Text::SimpleDateFormat.new("yyyy-MM", Java::Util::Locale::US)
        formattedDateUSA = usa.parse(date)
        brazil = Java::Util::Locale.new("pt", "BR")
        dateFormat = Java::Text::SimpleDateFormat.new("MMMM", brazil) 
        formattedDate = dateFormat.format(formattedDateUSA)
        formattedDate
    end   

    def has_actionbar_menu?
        true 
    end
end

