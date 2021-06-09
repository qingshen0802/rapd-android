class Utils

  def self.loading_dialog(activity)
    dialog = Android::App::Dialog.new(activity)
    dialog.requestWindowFeature(Android::View::Window::FEATURE_NO_TITLE)
    dialog.setContentView(R::Layout::Dialog)
    dialog.cancelable = false

    if !dialog.isShowing
      dialog.show
      dialog
    end
  end

  def self.show_dialog(activity, title, message)
    builder = Android::App::AlertDialog::Builder.new(activity)
    builder.message = message
    builder.title = title
    builder.cancelable = false
    builder.setPositiveButton("OK", DialogOnClickListener.new(activity))
    builder.show
  end

  def self.show_confirm_dialog(activity, delegate, action)
    builder = Android::App::AlertDialog::Builder.new(activity)
    builder.message = "Você tem certeza?"
    builder.title = "Alerta!"
    builder.cancelable = false
    builder.setPositiveButton("OK", DialogOnClickListener.new(activity, delegate, action))
    builder.setNegativeButton("Cancel", DialogOnClickListener.new(activity, delegate, action))
    builder.show
  end

  def self.select_image_dialog(activity, fragment)
    options = [ "Take photo", "Select from gallery", "Cancel" ]

    builder = Android::App::AlertDialog::Builder.new(activity)
    builder.title = "Add photo"
    builder.setItems(options, DialogClickImageDialog.new({activity: activity, fragment: fragment}))
    builder.show
  end

  def self.facebook_pw_dialog(activity)
    dialog = Android::App::Dialog.new(activity)
    dialog.requestWindowFeature(Android::View::Window::FEATURE_NO_TITLE)
    dialog.setContentView(R::Layout::Dialog_facebook)

    dialog.show
  end

  def self.is_logged(activity)
    Utils.get_preferences(activity).getBoolean("logged", false)
  end

  def self.get_preferences(activity)
    activity.getSharedPreferences("br.com.rubythree.Rapd", Android::Content::Context::MODE_PRIVATE)
  end

  def self.clear_preferences(activity)
    Utils.get_preferences(activity).edit.clear.apply
  end

  def self.decode_sampled_bitmap_from_uri(selected_image, req_width, req_height, content_resolver)
    options = Android::Graphics::BitmapFactory::Options.new
    options.inJustDecodeBounds = true

    Android::Graphics::BitmapFactory.decodeStream(content_resolver.openInputStream(selected_image), nil, options)

    height = options.outHeight
    width = options.outWidth
    inSampleSize = 1

    if (height > req_height || width > req_width)
      if width > height
        inSampleSize = (height.to_f / req_height.to_f).round
      else
        inSampleSize = (width.to_f / req_width.to_f).round
      end
    end

    options.inSampleSize = inSampleSize
    options.inJustDecodeBounds = false

    Android::Graphics::BitmapFactory.decodeStream(content_resolver.openInputStream(selected_image), nil, options)
  end

  def self.create_file(activity, bitmap)
    file = Java::Io::File.new(activity.getCacheDir(), "temp.jpg")
    fOut = Java::Io::FileOutputStream.new(file)

    bitmap.compress(Android::Graphics::Bitmap::CompressFormat::PNG, 85, fOut)
    fOut.flush()
    fOut.close()

    file
  end

  def self.disable_soft_keyboard(activity)
    activity.getWindow().setSoftInputMode(Android::View::WindowManager::LayoutParams::SOFT_INPUT_STATE_VISIBLE |
            Android::View::WindowManager::LayoutParams::SOFT_INPUT_ADJUST_RESIZE)
    activity.getSystemService(Android::Content::Context::INPUT_METHOD_SERVICE).hideSoftInputFromWindow(activity.getCurrentFocus().getWindowToken(), 0)
  end

  def self.disable_resize_on_keyboard_open(activity)
    activity.getWindow().setSoftInputMode(Android::View::WindowManager::LayoutParams::SOFT_INPUT_STATE_VISIBLE |
            Android::View::WindowManager::LayoutParams::SOFT_INPUT_ADJUST_PAN)
  end
  
  def self.get_typeface_from_asset(activity,font)
    Android::Graphics::Typeface.createFromAsset(activity.getAssets(), "fonts/Roboto/#{font}.ttf")
  end

  def self.format_money_br(value)
    "R$ #{format_money(value)}"
  end

  def self.format_money(value)
    ("%#.2f" % value.to_f).gsub(".",",").gsub(/(\d)(?=(\d{3})+\,\b)/,'\1.')
  end

  def self.insert_photo_for_circle_view(activity, options = {})
    if (options[:photo] != "/images/original/missing.png")
      Com::Squareup::Picasso::Picasso.with(activity.getBaseContext()).load(options[:photo]).into(options[:image_view]).placeholder(R::Drawable::Profile_placeholder).noFade
    end
  end
  
  def self.format_phone_number(phone_number)
    if phone_number.length == 10
      "(#{phone_number[0, 2]}) #{phone_number[2, 4]}-#{phone_number[6, 4]}"
    else
      "(#{phone_number[0, 2]}) #{phone_number[2, 5]}-#{phone_number[7, 4]}"
    end
  end
  
  def self.read_json_file_as_hash(context, file_name)
    json_string = Org::Apache::Commons::Io::IOUtils.toString(context.getAssets().open(file_name), Java::Nio::Charset::StandardCharsets::UTF_8)
    
    JSON.load(json_string)
  end
end
