class ConnectDeviceFragment < Android::Support::V4::App::DialogFragment

  include BaseView
  include FragmentManager

  attr_accessor :show_nfc

  def self.new_instance(show_nfc)
    connect_device_frag = ConnectDeviceFragment.new
    connect_device_frag.show_nfc = show_nfc
    connect_device_frag
  end

  def onCreateView(inflater, container, savedInstanceState)
    super
    fragmentOnCreateView(inflater, container, savedInstanceState)
  end

  def onStart
    super
    dialog = getDialog
    dialog.setCancelable(true)
    FullScreenDialogFragmentHelper.on_start(dialog)
  end

  def onCreateDialog(savedInstanceState)
    dialog = super
    FullScreenDialogFragmentHelper.on_create_dialog(dialog, savedInstanceState)
  end

  def onClick(button)
    super button
  end

  def has_actionbar?
    false
  end

  def nested_fragment?
    true
  end

  def load_views
    outlets["image"].setImageResource(get_drawable(self.show_nfc ? "nfc_icon" : "bluetooth_icon"))
    outlets["header"].text = get_string(self.show_nfc ? "connect_nfc" : "connect_bluetooth")
    outlets["instructions"].text = get_string(self.show_nfc ? "connect_nfc_instructions" : "connect_bluetooth_instructions")
    outlets["ok"].addTarget(self, action: "ok")
  end

  def ok
    dismiss()
  end

end