class ManageWalletFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    adapter = ProfileAdapter.new(self, load_table_data.first[:rows])
    outlets['options_list'].adapter = adapter
  end
  
  def get_title
    "Operações financeiras"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
  end
  
  def load_table_data
    [
      {rows: [
        {cell_type: "icon_title_subtitle", icon: "money_load_icon", title: "Carregar carteira", subtitle: "Carregue crédito nas suas moedas", disclosure: true, action: "load_money"},
        {cell_type: "icon_title_subtitle", icon: "money_withdraw_icon", title: "Resgatar", subtitle: "Resgate seu saldo", disclosure: true, action: "withdraw"},
        {cell_type: "icon_title_subtitle", icon: "money_conversion_icon", title: "Converter", subtitle: "Converta suas moedas", disclosure: true, action: "convert"},
        # {cell_type: "icon_title_subtitle", icon: "money_billings_icon", title: "Cobranças", subtitle: "Acesse as cobranças realizadas", disclosure: true, action: "transaction_requests"},
        {cell_type: "icon_title_subtitle", icon: "money_reports_icon", title: "Relatórios", subtitle: "Tenha uma visão geral do seu porfolio", disclosure: true, action: "reports"},
        {cell_type: "icon_title_subtitle", icon: "money_cards_icon", title: "Cartões de crédito", subtitle: "Agilize seus pagamentos", disclosure: true, action: "cards"},
        # {cell_type: "icon_title_subtitle", icon: "money_debit_card_icon", title: "Cartão de Débito", subtitle: "Peça já o seu", disclosure: true, action: "debitCard"},
      ]}

    ]
  end
  
  def onClick(button)
    super button
  end
  
  def onOptionsItemSelected(item)
    case item.getItemId()
    when Android::R::Id::Home
      getFragmentManager().popBackStack()
    end
    
    true
  end

  def load_money(i)
    switch_to_fragment('load_money', container: 'main', fragment_attributes: {back_destination: 'manage_wallet'})
  end

  def withdraw(i)
    switch_to_fragment('withdraw', container: 'main')
  end

  def cards(i)
    switch_to_fragment('credit_cards', container: 'main', fragment_attributes: {profile: self.profile})
  end

  def convert(i)
    switch_to_fragment('convert_currency', container: 'main')
  end

  def reports(i)
    switch_to_fragment('report', container: 'main')
  end

end
