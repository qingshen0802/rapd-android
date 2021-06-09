class MapFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
    
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    frag = Com::Google::Android::Gms::Maps::SupportMapFragment.newInstance
    frag.getMapAsync(self)
    fragmentManager = getActivity().getSupportFragmentManager()
    fragmentTransaction = fragmentManager.beginTransaction
    fragmentTransaction.add(R::Id::Mapwhere, frag)
    fragmentTransaction.commit();
  end
  
  def onMapReady(googleMap) 
    sydney = Com::Google::Android::Gms::Maps::Model::LatLng.new(-33.852, 151.211)
    googleMap.addMarker(Com::Google::Android::Gms::Maps::Model::MarkerOptions.new.position(sydney).title("Restaurant Name").snippet("Address"))
    googleMap.moveCamera(Com::Google::Android::Gms::Maps::CameraUpdateFactory.newLatLngZoom(sydney,12))
  end
  
  def get_title
  end
  
  def nested_fragment?
    true
  end
  
  def onClick(button)
    super button
  end
  

end
