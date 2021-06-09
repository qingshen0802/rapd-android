class Document < BaseEntity

  attr_accessor :position, :attachment, :attachment_mime_type, :document_description, :profile_id, :approval_status, :user_id, :attachment_url

  def any_attachment?
    attachment
  end
  
  def approved?
    approval_status == 'approved'
  end
  
end