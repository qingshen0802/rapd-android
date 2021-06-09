class ImageListener

  attr_accessor :image_view

  def initialize(image_view)
    @image_view = image_view
  end

  def onLoadingComplete(imageUri, view, loadedImage)
    if loadedImage != nil
      @image_view.setImageBitmap(loadedImage)
    end
  end

end