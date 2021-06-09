class NotificationFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :order_filter, :type_filter, :notifications
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def get_title
    get_string('notification_title')
  end
    
  def load_views
    manager = NotificationManager.shared_manager
    manager.delegate = self
    manager.fetch_all({type: type_filter_api, order: order_filter_api})
  end
  
  def items_fetched (notifications)
    @notification_list = outlets['notification_table']
    @adapter = NotificationAdapter.new(self, generate_rows(notifications))
    @notification_list.adapter = @adapter
    @notification_list.onItemClickListener = self
  end

  def onItemClick(parent, view, position, id)
    if @adapter.getItem(position)[:cell_type] != "divider"
      notification = @adapter.getItem(position)[:notification]
      if notification.type.include? "WarningNotification"
        switch_to_fragment("notification_warning", container: 'main', fragment_attributes: {notification: notification})
      elsif notification.type.include? "PaymentRequestNotification"
        if notification.title.include? "Solicitação de pagamento enviada"
          switch_to_fragment("notification_request_cancel", container: 'main', fragment_attributes: {notification: notification})
        else
          switch_to_fragment("notification_request_accept", container: 'main', fragment_attributes: {notification: notification})
        end
      elsif notification.type.include? "MentionNotification"
        switch_to_fragment("notification_mention", container: 'main', fragment_attributes: {notification: notification})
      elsif notification.type.include? "MessageNotification"
        switch_to_fragment("notification_message", container: 'main', fragment_attributes: {notification: notification})
      elsif notification.type.include? "PromotionNotification"
        switch_to_fragment("notification_promotion", container: 'main', fragment_attributes: {notification: notification})
      elsif notification.type.include? "PaymentNotification"
        switch_to_fragment("notification_payment", container: 'main', fragment_attributes: {notification: notification})
      elsif notification.type.include? "ReceiptNotification"
        switch_to_fragment("notification_receipt", container: 'main', fragment_attributes: {notification: notification})
      end
    end
  end

  def onClick(button)
    super(button)
  end
  
  def action_bar_filters
    switch_to_fragment("categories", container: "main", fragment_attributes: {order_filter: self.order_filter, type_filter: self.type_filter, referrer_fragment: 'notification'})
  end
  
  def has_actionbar_menu?
    true
  end
  
  def is_today?(date)
    date == Time.now.strftime('%F')
  end
  
  def is_yesterday?(date)
    date == (Time.now - (60 * 60 * 24) ).strftime('%F')
  end
  
  def notification_cell (notification)
    {cell_type: "custom_row_notification_item", icon: "money_load_icon", notification: notification, title: notification.title, subtitle: notification.description, disclosure: true, action: "load_money"}
  end
  
  def generate_rows(notifications)
    rows = []
    self.notifications = []
    notifications.group_by(&:created_at).map do |k,v|
      rows << get_date_cell(k.split('T')[0])
      v.each{|notification|
        rows << self.notification_cell(notification)
        self.notifications << notification
      }
    end
    rows
  end
  
  def locale(date)
      usa = Java::Text::SimpleDateFormat.new("yyyy-MM-dd", Java::Util::Locale::US)
      formattedDateUSA = usa.parse(date)
      dateFormat = Java::Text::SimpleDateFormat.new("dd/MM/yyyy", Java::Util::Locale::US) 
      formattedDate = dateFormat.format(formattedDateUSA)
      formattedDate
  end 
  
  def get_date_cell (date)
    if is_today?(date)
      {cell_type: "divider", title: "Hoje"}
    elsif is_yesterday?(date)
      {cell_type: "divider", title: "Ontem (#{locale(date)})"}
    else
      {cell_type: "divider", title: "#{locale(date)}"}
    end
  end
  
  def order_filter_api
    case self.order_filter
    when "Mais Recentes"
      'newest'
    when "Mais antigas"
      'older'
    else
      nil
    end
  end
  
  def type_filter_api
    translation = {:'Pagamentos' => 'payment' ,:'Recebimentos' => 'receipt', :'Solicitações de pagamento' =>  'paymentRequest',
                    :'Avisos' => 'warning', :'Promoções' => 'promotion', :'Mensagem' => 'message'}
    return translation[:"#{self.type_filter}"] unless self.type_filter.nil?
    nil
  end
end