class CvvUtils {
  static final _CVV4_BINS = ['32', '33', '34', '37'];

  static bool isCvv4Length(String cardNumber) {
    for (String bin in _CVV4_BINS) {
      if (cardNumber.startsWith(bin)) {
        return true;
      }
    }
    return false;
  }
}