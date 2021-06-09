class MonthReportAdapter < Android::Widget::BaseAdapter
  include BaseView
  include AdapterManager
  
  def initialize(fragment, objects)
      self.fragment = fragment
      self.activity = fragment.getActivity
      self.objects = objects 
  end

  def getCount
      objects.length
  end

  def getItem(i)
      objects[i]
  end

  def getItemId(i)
      i
  end

  def getView(i, view, view_group)
    row =  getItem(i)

    case row[:cell_type]
    when "custom_row_charge_date"
        view = init_row 'custom_row_charge_date'
        outlets['date_text'].text = row[:date_text]

    when "custom_row_charge_credit"
      view = init_row 'custom_row_charge_credit'
      # if row[:transaction_type] == get_string('transaction_waiting')
      #   outlets['transaction_type'].text = get_string('waiting')
      #   outlets['credit_value'].setTextColor(colors(0))
      # elsif row[:transaction_type] == get_string('transaction_paid')
      #   outlets['transaction_type'].text = get_string('paid')
      #   outlets['credit_value'].setTextColor(colors(1))
      # elsif row[:transaction_type] == get_string('transaction_canceled')
      #   outlets['transaction_type'].text = get_string('canceled')
      #   outlets['credit_value'].setTextColor(colors(2))
      # end
      outlets['user_nick'].text = "@#{row[:user_nick]}"
      if row[:amount] >= 0
        outlets['credit_value'].setTextColor(colors(1))
        outlets['credit_value'].text = "#{app_delegate.current_currency.short_name}#{Utils.format_money(row[:amount])}"
      else
        outlets['credit_value'].setTextColor(colors(0))
        outlets['credit_value'].text = "-#{app_delegate.current_currency.short_name}#{Utils.format_money(row[:amount].abs)}"
      end
      Utils.insert_photo_for_circle_view(activity, {photo: row[:photo_url], image_view: outlets['user_photo_report']})
      view.addTarget(fragment, action: row[:action], i)
      end
    view
  end

  def colors(i)
      colorsArray = [Android::Graphics::Color.parseColor("#F15E4F"),
                     Android::Graphics::Color.parseColor("#2CC55E"), 
                     Android::Graphics::Color.parseColor("#FF0000")]
      return colorsArray[i] 
  end 
end