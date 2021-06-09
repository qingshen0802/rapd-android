@android.webkit.JavascriptInterface
public void cardHashGenerated(final java.lang.String cardHash) {
    card_hash_generated(cardHash);
}

@android.webkit.JavascriptInterface
public void logError(java.lang.String error) {
    log_error(error);
}

@android.webkit.JavascriptInterface
public java.lang.String getPagarMeKey() {
    return (java.lang.String) get_pagarme_enc_key();
}