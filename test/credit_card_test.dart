import 'package:flutter_test/flutter_test.dart';

import 'package:cloudipsp_mobile/src/credit_card.dart';

void main() {
  test('should fail validation card number by length', () {
    final c1 = PrivateCreditCard('4444', 0, 0, '');
    final c2 = PrivateCreditCard('12345678901234567890', 0, 0, '');

    expect(c1.isValidCardNumber(), false);
    expect(c2.isValidCardNumber(), false);
  });
  test('should pass validation card number with luna', () {
    final c = PrivateCreditCard('4444555566661111', 0, 0, '');

    expect(c.isValidCardNumber(), true);
  });

  test('should fail validation card number with luna', () {
    final c = PrivateCreditCard('4444555566661110', 0, 0, '');

    expect(c.isValidCardNumber(), false);
  });

  test('should fail validation exp mm', () {
    final c1 = PrivateCreditCard('', 0, 0, '');
    final c2 = PrivateCreditCard('', 100, 0, '');

    expect(c1.isValidExpireMonth(), false);
    expect(c2.isValidExpireMonth(), false);
  });

  test('should pass validation exp mm', () {
    final c1 = PrivateCreditCard('', 1, 0, '');
    final c2 = PrivateCreditCard('', 12, 0, '');

    expect(c1.isValidExpireMonth(), true);
    expect(c2.isValidExpireMonth(), true);
  });

  test('should fail validation exp yy', () {
    final c1 = PrivateCreditCard('', 0, 20, '');
    final c2 = PrivateCreditCard('', 0, 100, '');

    expect(c1.isValidExpireYear(), false);
    expect(c2.isValidExpireYear(), false);
  });

  test('should pass validation exp yy', () {
    final c = PrivateCreditCard('', 0, 25, '');

    expect(c.isValidExpireYear(), true);
  });

  test('should fail validation exp date', () {
    final c = PrivateCreditCard('', 11, 20, '');

    expect(c.isValidExpireDate(), false);
  });

  test('should pass validation exp date', () {
    final c = PrivateCreditCard('', 11, 25, '');

    expect(c.isValidExpireDate(), true);
  });

  test('should fail validation cvv', () {
    final c1 = PrivateCreditCard('', 0, 0, '');
    final c2 = PrivateCreditCard('', 0, 0, '12345');

    expect(c1.isValidCvv(), false);
    expect(c2.isValidCvv(), false);
  });

  test('should pass validation for 3 digit cvv card', () {
    final c = PrivateCreditCard('4444555566661111', 0, 0, '123');
    expect(c.isValidCvv(), true);
  });

  test('should pass validation for 4 digit cvv card', () {
    final c = PrivateCreditCard('3244555566661111', 0, 0, '1234');
    expect(c.isValidCvv(), true);
  });

  test('should fail validation for bad card', () {
    final c = PrivateCreditCard('4444555566661110', 13, 20, '12345');
    expect(c.isValid(), false);
  });

  test('should pass validation for good card', () {
    final c = PrivateCreditCard('4444555566661111', 11, 25, '123');
    expect(c.isValid(), true);
  });
}
