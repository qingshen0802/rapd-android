class ContactListViewPagerAdapter < Android::Support::V4::App::FragmentPagerAdapter
  
  include AdapterManager
  
  
  def getItem(i)
    types = ["Favorite","Telephone", "Contact"]
    fragment = ContactListContentFragment.new()
    fragment.type = types[i]
    fragment
  end

  def getCount
    3
  end
  

  def getPageTitle(position)
    titles = ["FAVORITOS","TELEFONES","USUÁRIOS"] 
    titles[position]
  end
end