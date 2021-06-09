class CreditCardAdapter < Android::Widget::BaseAdapter
  include AdapterManager
  attr_accessor :parent

  def initialize(parent, objects)
    self.parent = parent
    self.activity = parent.getActivity
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
    card = getItem i
    view = init_row card[:cell_type]
    card_type = card[:card_type_id]
    if card_type == 1
      outlets["card_layout"].setBackgroundResource(asset("round_visa_background"))
      outlets["card_flag"].setImageResource(asset("ic_visa"))
    elsif card_type == 2
      outlets["card_layout"].setBackgroundResource(asset("round_mastercard_background"))
      outlets["card_flag"].setImageResource(asset("ic_mastercard"))
    elsif card_type == 3
      outlets["card_layout"].setBackgroundResource(asset("round_american_express_background"))
      outlets["card_flag"].setImageResource(asset("ic_american_express"))
    else
      outlets["card_layout"].setBackgroundResource(asset("round_visa_background"))
      outlets["card_flag"].setImageResource(asset("ic_visa"))
    end

    outlets["card_number_end"].text = get_string("obstructed_card_number") % card[:last_four_digits]
    outlets["expire_date"].text = "Cadastrado em #{card[:expiry_date]}"
    outlets["toggle_alert"].setChecked(true) if card[:is_default_card]

    outlets["card_settings"].addTarget(parent, action: "edit_card", i)
    outlets["card_layout"].addTarget(parent, action: "choose_card_for_transaction", i)
    outlets["toggle_alert"].addTarget(parent, action: "set_card_as_default", i)

    view
  end

  # def card_type_map(remote_type)
  #   {
  #     "visa" => "visa",
  #     "master_card" => "mastercard",
  #     "amex" => "american_express",
  #     "unknown" => "visa"
  #   }[remote_type]
  # end

  def update_objects(objects)
    self.objects = objects
    notifyDataSetChanged
  end
end