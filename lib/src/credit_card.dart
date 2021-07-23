import './cvv_utils.dart';

enum CardType {
  VISA,
  MASTERCARD,
  MAESTRO,
  UNKNOWN
}

abstract class CreditCard {
  bool isValidCardNumber();

  bool isValidExpireMonth();

  bool isValidExpireYear();

  bool isValidExpireDate();

  bool isValidCvv();

  bool isValid();
}

class PrivateCreditCard implements CreditCard {
  final String cardNumber;
  final int mm;
  final int yy;
  final String cvv;

  PrivateCreditCard(this.cardNumber, this.mm, this.yy, this.cvv): super();


  @override
  bool isValidCardNumber() {
    if (!(12 <= cardNumber.length && cardNumber.length <= 19)) {
      return false;
    }
    if (!_lunaCheck(cardNumber)) {
      return false;
    }
    return true;
  }

  @override
  bool isValidExpireMonth() {
    return mm >= 1 && mm <= 12;
  }

  bool _isValidExpireYearValue() {
    return yy >= 21 && yy <= 99;
  }

  @override
  bool isValidExpireYear() {
    if (!_isValidExpireYearValue()) {
      return false;
    }
    final year = DateTime.now().year - 2000;
    return year <= yy;
  }

  @override
  bool isValidExpireDate() {
    if (!isValidExpireMonth()) {
      return false;
    }
    if (!isValidExpireYear()) {
      return false;
    }
    final now = DateTime.now();
    final year = now.year - 2000;
    return (yy > year) || (yy == year && mm >= now.month);
  }


  @override
  bool isValidCvv() {
    if (CvvUtils.isCvv4Length(cardNumber)) {
      return cvv.length == 4;
    } else {
      return cvv.length == 3;
    }
  }

  bool isValid() {
    return isValidCardNumber() && isValidExpireDate() && isValidCvv();
  }

  static bool _lunaCheck(String cardNumber) {
    int sum = 0;
    bool odd = true;
    for (int i = cardNumber.length - 1; i >= 0; --i) {
      try {
        int num = int.parse(cardNumber[i]);

        odd = !odd;
        if (odd) {
          num *= 2;
        }
        if (num > 9) {
          num -= 9;
        }
        sum += num;
      } catch (e) {
        return false;
      }
    }

    return sum % 10 == 0;
  }
}