class NoBalanceFragment < Android::Support::V4::App::DialogFragment

  include BaseView
  include FragmentManager

  def self.new_instance
    NoBalanceFragment.new
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

  def onClick(view)
    super(view)
  end

  def has_actionbar?
    false
  end

  def nested_fragment?
    true
  end

  def load_views
    outlets["dismiss"].addTarget(self, action: "dismiss")
    outlets["load_funds"].addTarget(self, action: "load_funds")
  end

  def load_funds
    switch_to_fragment('load_money', container: 'main')
    dismiss
  end

end
