class DocumentUploadFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :current_picker_position, :front_document_changed, :back_document_changed, :top_photo, :bottom_photo, :front_document, :back_document, :current_document_upload, :document_manager
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    outlets['send_document_front'].addTarget(self, action: 'send_document_front')
    outlets['send_document_back'].addTarget(self, action: 'send_document_back')
  end
  
  def get_title
    "Meus documentos"
  end
  
  def has_back_arrow?
    true
  end
  
  def has_drawer_toggle?
    false
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
  
  def send_document_front
    self.current_picker_position = 'top'
    select_image
  end
  
  def send_document_back
    self.current_picker_position = 'bottom'
    select_image
  end
  
  def onActivityResult(requestCode, resultCode, data)
    super
    
    if resultCode == Android::App::Activity::RESULT_OK
      selected_image = data.getData()
      
      if selected_image
        bitmap = Utils.decode_sampled_bitmap_from_uri(selected_image, 500, 500, getActivity.getContentResolver)
      else
        bitmap = data.getExtras.get("data")
      end
      
      case current_picker_position
      when 'top'
        self.front_document_changed = true
        self.top_photo = Utils.create_file(getActivity, bitmap)
        outlets['send_document_front'].set_gone
      when 'bottom'
        self.back_document_changed = true
        self.bottom_photo = Utils.create_file(getActivity, bitmap)
        outlets['send_document_back'].set_gone
      end
      
      if top_photo != nil && bottom_photo != nil
        send_photos
      end
    end
  end
  
  def send_photos
    self.front_document = Document.new if self.front_document.nil?
    self.front_document.attachment = top_photo
    self.front_document.profile_id = profile.remote_id
    self.front_document.position = 'front'
    self.front_document.approval_status = 'pending'

    self.back_document = Document.new if self.back_document.nil?
    self.back_document.attachment = bottom_photo
    self.back_document.profile_id = profile.remote_id
    self.back_document.position = 'back'
    self.front_document.approval_status = 'pending'
    
    self.document_manager = DocumentManager.shared_manager
    self.document_manager.delegate = self
  
    if self.front_document_changed
      upload_document('front')
    elsif self.back_document_changed
      upload_document('back')
    end
  end
  
  def upload_document(position)
    @dialog = Utils.loading_dialog(getActivity)

    self.current_document_upload = position
    
    unless position.nil?
      if self.send("#{position}_document").new_record?
        self.document_manager.create_resource(send("#{position}_document"))
      else
        self.document_manager.update_resource(send("#{position}_document"))
      end
    end
  end
  
  def resource_created(resource)
    @dialog.dismiss
    self.send("#{current_document_upload}_document=", resource)
    
    case current_document_upload
    when 'front'
      self.current_document_upload = nil
      self.front_document_changed = false
      if self.back_document_changed
        upload_document('back')
      else
        uploads_finished
      end
    when 'back'
      self.current_document_upload = nil
      self.back_document_changed = false
      if self.front_document_changed
        upload_document('front')
      else
        uploads_finished
      end
    end
  end
  
  def resource_updated(resource)
    @dialog.dismiss
    self.send("#{current_document_upload}_document=", resource)
    
    case current_document_upload
    when 'front'
      self.current_document_upload = nil
      self.front_document_changed = false
      if self.back_document_changed
        upload_document('back')
      else
        uploads_finished
      end
    when 'back'
      self.current_document_upload = nil
      self.back_document_changed = false
      if self.front_document_changed
        upload_document('front')
      else
        uploads_finished
      end
    end
  end
  
  def uploads_finished
    getFragmentManager().popBackStack()
  end
  
end
