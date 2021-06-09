class DialogClickImageDialog

  attr_accessor :fragment, :activity

  def initialize(hash)
    @fragment = hash[:fragment]
    @activity = hash[:activity]
  end

  def onClick(dialog, item)
    if item.to_i == 0
      intent = Android::Content::Intent.new(Android::Provider::MediaStore::ACTION_IMAGE_CAPTURE)

      if fragment != nil
        fragment.startActivityForResult(intent, 0)
      else
        activity.startActivityForResult(intent, 0)
      end
    elsif item.to_i == 1
      intent = Android::Content::Intent.new(Android::Content::Intent::ACTION_GET_CONTENT)
      intent.type = "image/*"

      if fragment != nil
        fragment.startActivityForResult(intent, 0)
      else
        activity.startActivityForResult(intent, 0)
      end
    else
      dialog.dismiss
    end
  end

end
