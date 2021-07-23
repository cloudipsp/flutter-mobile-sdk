import 'package:flutter_test/flutter_test.dart';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';

import './utils.dart';

void main() {
  group('constructor', ()
  {
    test('should throw exception with wrong amount', () {
      expect(() => Order(-1, '', '', '', ''),
          thrownArgumentError('Amount should be more than 0'));
    });

    test('should throw exception with null currency', () {
      expect(() => Order(1, null, '', '', ''),
          thrownArgumentErrorNotNull('currency'));
    });
    test('should throw exception with invalid currency', () {
      expect(() => Order(1, 'UA', '', '', ''),
          thrownArgumentErrorValue('UA', 'currency'));
    });

    test('should throw exception with null id', () {
      expect(() => Order(1, 'UAH', null, '', ''),
          thrownArgumentErrorNotNull('id'));
    });
    test('should throw exception invalid(empty) id', () {
      expect(() => Order(1, 'UAH', '', '', ''),
          thrownArgumentError("id's length should be > 0 && <= 1024"));
    });

    test('should throw exception with null description', () {
      expect(() => Order(1, 'UAH', 'OrderID', null, ''),
          thrownArgumentErrorNotNull('description'));
    });
    test('should throw exception with invalid(empty) description', () {
      expect(() => Order(1, 'UAH', 'OrderID', '', ''),
          thrownArgumentError("description's length should be > 0 && <= 1024"));
    });

    test('should throw exception with invalid email', () {
      expect(() => Order(1, 'UAH', 'OrderID', 'Test', 'blahblah'),
          thrownArgumentError("email is not valid"));
    });

    test('should create order as well with null email', () {
      final o = Order(1, 'UAH', 'OrderID', 'Test', null);
      expect(o.amount, 1);
      expect(o.currency, 'UAH');
      expect(o.id, 'OrderID');
      expect(o.description, 'Test');
      expect(o.email, null);
    });

    test('should create order as well with empty email', () {
      final o = Order(21, 'USD', 'OrderID2', 'Test2', '');
      expect(o.amount, 21);
      expect(o.currency, 'USD');
      expect(o.id, 'OrderID2');
      expect(o.description, 'Test2');
      expect(o.email, '');
    });

    test('should create order as well with valid email', () {
      final o = Order(3, 'EUR', 'OrderID3', 'Test3', 'example@test.com');
      expect(o.amount, 3);
      expect(o.currency, 'EUR');
      expect(o.id, 'OrderID3');
      expect(o.description, 'Test3');
      expect(o.email, 'example@test.com');
    });
  });

  group('params', ()
  {
    Order order;

    setUp(() {
      order = Order(1, 'UAH', '1234-45', 'Nice :)', 'example@test.com');
    });

    tearDown(() {
      order = null;
    });

    group('productId', () {
      test('should throw exception with null value', () {
        expect(() => order.productId = null,
            thrownArgumentErrorNotNull('ProductId'));
      });
      test('should throw exception with invalid(huge) value', () {
        expect(() => order.productId = getRandomString(2000),
            thrownArgumentError('ProductId should be not more than 1024 symbols'));
      });
      test('should save valid value', () {
        order.productId = 'SomeRandomProductId';
        expect(order.productId, 'SomeRandomProductId');
      });
    });

    group('paymentSystems', () {
      test('should throw exception with null value', () {
        expect(() => order.paymentSystems = null,
            thrownArgumentErrorNotNull('paymentSystems'));
      });
      test('should save valid value', () {
        order.paymentSystems = 'SomeRandomPaymentSystem';
        expect(order.paymentSystems, 'SomeRandomPaymentSystem');
      });
    });

    group('defaultPaymentSystem', () {
      test('should throw exception with null value', () {
        expect(() => order.defaultPaymentSystem = null,
            thrownArgumentErrorNotNull('defaultPaymentSystem'));
      });
      test('should save valid value', () {
        order.defaultPaymentSystem = 'SomeRandomDefaultPaymentSystem';
        expect(order.defaultPaymentSystem, 'SomeRandomDefaultPaymentSystem');
      });
    });

    group('merchantData', () {
      test('should throw exception with null value', () {
        expect(() => order.merchantData = null,
            thrownArgumentErrorNotNull('merchantData'));
      });
      test('should throw exception with invalid(huge) value', () {
        expect(() => order.merchantData = getRandomString(2049),
            thrownArgumentError('MerchantData should be not more than 2048 symbols'));
      });
      test('should save valid value', () {
        order.merchantData = 'SomeRandomMerchantData';
        expect(order.merchantData, 'SomeRandomMerchantData');
      });
    });

    group('verificationType', () {
      test('should throw exception with null value', () {
        expect(() => order.verificationType = null,
            thrownArgumentErrorNotNull('verificationType'));
      });
      test('should save valid(amount) value', () {
        order.verificationType = Verification.amount;
        expect(order.verificationType, Verification.amount);
      });
      test('should save valid(code) value', () {
        order.verificationType = Verification.code;
        expect(order.verificationType, Verification.code);
      });
    });

    group('recToken', () {
      test('should throw exception with null value', () {
        expect(() => order.recToken = null,
            thrownArgumentErrorNotNull('recToken'));
      });
      test('should save valid value', () {
        order.recToken = 'SomeRandomRecToken';
        expect(order.recToken, 'SomeRandomRecToken');
      });
    });

    group('version', () {
      test('should throw exception with null value', () {
        expect(() => order.version = null,
            thrownArgumentErrorNotNull('version'));
      });
      test('should throw exception with invalid(huge) value', () {
        expect(() => order.version = getRandomString(11),
            thrownArgumentError('version should be not more than 10 symbols'));
      });
      test('should save valid value', () {
        order.version = '2.0';
        expect(order.version, '2.0');
      });
    });

    group('lang', () {
      test('should throw exception with null value', () {
        expect(() => order.lang = null,
            thrownArgumentErrorNotNull('lang'));
      });
      test('should save valid(uk) value', () {
        order.lang = Lang.uk;
        expect(order.lang, Lang.uk);
      });
      test('should save valid(en) value', () {
        order.lang = Lang.en;
        expect(order.lang, Lang.en);
      });
    });

    group('serverCallbackUrl', () {
      test('should throw exception with null value', () {
        expect(() => order.serverCallbackUrl = null,
            thrownArgumentErrorNotNull('serverCallbackUrl'));
      });
      test('should throw exception with invalid(huge) value', () {
        expect(() => order.serverCallbackUrl = getRandomString(2049),
            thrownArgumentError('server callback url should be not more than 2048 symbols'));
      });
      test('should save valid value', () {
        order.serverCallbackUrl = 'SomeRandomServerCallbackUrl';
        expect(order.serverCallbackUrl, 'SomeRandomServerCallbackUrl');
      });
    });

    group('reservationData', () {
      test('should throw exception with null value', () {
        expect(() => order.reservationData = null,
            thrownArgumentErrorNotNull('reservationData'));
      });
      test('should save valid value', () {
        order.reservationData = 'SomeRandomReservationData';
        expect(order.reservationData, 'SomeRandomReservationData');
      });
    });

    test('should be able to add extra argument', () {
      order.addArgument('MySuperUniqueArgumentName', 'MySuperUniqueArgumentValue');
      expect(order.arguments['MySuperUniqueArgumentName'], 'MySuperUniqueArgumentValue');
    });
  });
}
