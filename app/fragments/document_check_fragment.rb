class DocumentCheckFragment < Android::Support::V4::App::Fragment

  include BaseView
  include FragmentManager
  
  attr_accessor :profile, :documents
  
  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end
  
  def load_views
    load_profile
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
  
  def load_profile
    profile_manager = ProfileManager.shared_manager
    profile_manager.delegate = self
    profile_manager.fetch(app_delegate.current_profile_id)
  end
  
  def item_fetched(profile)
    self.profile = profile
    display_documents
  end
  
  def display_documents
    case profile.current_document_status
    when 'never_sent', '', nil
      never_sent
    when 'all_approved'
      all_approved
    when 'contains_pending'
      contains_pending
    when 'contains_declined'
      contains_declined
      load_documents
    end    
  end
  
  def load_documents
    document_manager = DocumentManager.shared_manager
    document_manager.delegate = self
    document_manager.fetch_all(profile_id: profile.remote_id)
  end
  
  def items_fetched(documents)
    self.documents = documents
    
    adapter = DocumentAdapter.new(self, document_rows)
    outlets['documents_list'].adapter = adapter
  end
  
  def document_rows
    self.documents ||= []
    return [] if self.documents.count == 0
    
    documents.map do |document|
      translated_position = document.position == 'front' ? 'A frente' : 'O verso'
      noun = document.position == 'front' ? 'a' : 'o'

      if document.approved?
        title = "Documento aprovado"
        subtitle = "#{translated_position} do documento foi aprovad#{noun} e você não precisa realizar nenhuma ação"
      else
        title = "Documento rejeitado"
        subtitle = "#{translated_position} do documento não foi aceit#{noun}. A imagem não está legível. Por favor, re-envie"
      end

      {cell_type: "document_status", title: title, subtitle: subtitle, status_icon: document.approved? ? "ic_approved" : "ic_rejected", disclosure: !document.approved?, disabled: document.approved?, action: "check_documents"}
    end
  end
  
  def never_sent
    outlets['confirm_document_text'].set_visible
    outlets['analyzing_documents_layout'].set_gone
    outlets['approved_documents_layout'].set_gone
    outlets['insert_documents'].set_visible
    
    outlets['insert_documents'].addTarget(self, action: "continue")
  end
  
  def contains_pending
    outlets['confirm_document_text'].set_gone
    outlets['analyzing_documents_layout'].set_visible
    outlets['approved_documents_layout'].set_gone
    outlets['insert_documents'].set_gone
  end  
  
  def all_approved
    outlets['confirm_document_text'].set_gone
    outlets['analyzing_documents_layout'].set_gone
    outlets['approved_documents_layout'].set_visible
    outlets['insert_documents'].set_gone
  end
  
  def contains_declined
    outlets['confirm_document_text'].set_gone
    outlets['analyzing_documents_layout'].set_gone
    outlets['approved_documents_layout'].set_gone
    outlets['insert_documents'].set_visible
    
    outlets['insert_documents'].addTarget(self, action: "continue")
  end
  
  def continue
    switch_to_fragment('document_upload', container: 'main', fragment_attributes: {profile: profile})
  end
  
  def check_documents
    continue
  end
  
end
