class UploadRecieptFragment < Android::Support::V4::App::Fragment
  include BaseView
  include FragmentManager

  attr_accessor :transaction

  def onCreateView(inflater, container, savedInstanceState)
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def get_title
    get_string "upload_reciept_title"
  end

  def has_actionbar?
    true
  end

  def has_back_arrow?
    true
  end

  def onClick(view)
    super view
  end

  def onActivityResult(req_code, res_code, data)
    super

    if res_code == Android::App::Activity::RESULT_OK
      selected_image = data.getData()
      
      if selected_image
        bitmap = Utils.decode_sampled_bitmap_from_uri(selected_image, 500, 500, getActivity.getContentResolver)
      else
        bitmap = data.getExtras.get("data")
      end
      
      @attachment = Utils.create_file(getActivity, bitmap)
      update_transaction
    end
  end

  def load_views
    outlets["upload"].addTarget(self, action: "select_image")
  end

  def update_transaction
    @dialog = Utils.loading_dialog getActivity
    transaction_manager = TransactionManager.shared_manager
    transaction_manager.delegate = self
    transaction_manager.update_resource build_transaction

  end

  def build_transaction
    Transaction.new({
      remote_id: self.transaction.remote_id,
      attachment: @attachment
    })
  end

  def resource_updated(transaction)
    @dialog.dismiss
    go_back
  end

  def resource_update_failed
    @dialog.dismiss
  end
end
