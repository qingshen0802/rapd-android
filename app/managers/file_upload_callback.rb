class FileUploadCallback

  def onStart()
    p "====== START"
  end

  def onHttpCallbackFinish()
    p "====== FINISH"
  end

end