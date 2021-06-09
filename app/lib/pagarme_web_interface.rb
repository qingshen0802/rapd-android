class PagarmeWebInterface
  attr_accessor :context, :delegate

  def initialize(context, delegate)
    self.context = context
    self.delegate = delegate
  end

  __annotation__("@android.webkit.JavascriptInterface")
  def card_hash_generated(card_hash)
    delegate.card_hash_generated card_hash
  end

  __annotation__("@android.webkit.JavascriptInterface")
  def log_error(error)
    puts "error: #{error}"
  end

  __annotation__("@android.webkit.JavascriptInterface")
  def show_error
    delegate.card_hash_gen_error
  end

  __annotation__("@android.webkit.JavascriptInterface")
  def get_pagarme_enc_key
    # delegate.get_string "pagarme_prod_key"
    delegate.get_string "pagarme_test_key"
  end

end