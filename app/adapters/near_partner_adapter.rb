class NearPartnerAdapter < Android::Widget::BaseAdapter
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
    profile =  getItem(i)
    view = init_row 'custom_row_partner'
    outlets['partner_name'].text = profile.full_name
    insert_photo(image_view: outlets['partner_logo'], photo: profile.photo_url)

    outlets['partner_credit'].set_gone if profile.discount_club_bonus_amount.nil?
    outlets['partner_credit'].text = "Você tem R$ #{profile.discount_club_bonus_amount} em dito"
    # outlets['partner_distance'].text = profile.distance
    outlets['partner_user_name'].text = "@#{profile.username}"
    view
  end
end