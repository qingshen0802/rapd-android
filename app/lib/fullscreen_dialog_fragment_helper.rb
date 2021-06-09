class FullScreenDialogFragmentHelper
  def self.on_start(dialog)
    window = dialog.getWindow

    window.setGravity(Android::View::Gravity::CENTER_HORIZONTAL | Android::View::Gravity::BOTTOM)
    window.setBackgroundDrawable(Android::Graphics::Drawable::ColorDrawable.new(Android::Graphics::Color::TRANSPARENT))
    params = window.getAttributes
    params.width = Android::View::ViewGroup::LayoutParams::MATCH_PARENT
    params.height = Android::View::ViewGroup::LayoutParams::MATCH_PARENT
    params.horizontalMargin = 0;
    params.verticalMargin = 0;

    window.setAttributes params
    window.clearFlags(Android::View::WindowManager::LayoutParams::FLAG_DIM_BEHIND);
  end

  def self.on_create_dialog(dialog, savedInstanceState)
    dialog.getContext.setTheme(R::Style::BottomToUpTheme)
    dialog
  end
end