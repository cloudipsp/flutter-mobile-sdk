import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:http/http.dart' as http;

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/api.dart';
import 'package:cloudipsp_mobile/src/credit_card.dart';
import 'package:cloudipsp_mobile/src/platform_specific.dart';

import './api_test.mocks.dart';
import './utils.dart';

@GenerateMocks([PlatformSpecific, http.Client])
void main() {
  late Api api;
  late MockClient mockedHttpClient;
  late MockPlatformSpecific mockedPlatformSpecific;
  late Order order;

  setUp(() {
    mockedHttpClient = MockClient();
    mockedPlatformSpecific = MockPlatformSpecific();
    api = Api.withHttpClient(mockedPlatformSpecific, mockedHttpClient, false);
    order = Order(123, 'UAH', '1234-45', 'Nice :)', 'example@test.com');

    when(mockedPlatformSpecific.operatingSystem).thenReturn('UnitTestOS');
  });

  group('getPaymentConfig', () {
    group('amount,currency,merchant', () {
      test('should should throw exception with unknown methodId', () async {
        when(mockedHttpClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
                (_) async => http.Response(RESPONSE_GET_PAYMENT_CONFIG, 200));

        await expectLater(
            () => api.getPaymentConfig(
                merchantId: 100500,
                amount: 123,
                currency: 'UAH',
                methodId: 'TestMethodId404',
                methodName: 'TestMethodName404'),
            thrownUnsupported(
                'TestMethodName404 is not supported for merchant 100500 and currency UAH'));
      });

      test('should proceed successfully', () async {
        when(mockedHttpClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
                (_) async => http.Response(RESPONSE_GET_PAYMENT_CONFIG, 200));

        final config = await api.getPaymentConfig(
            merchantId: 100500,
            amount: 123,
            currency: 'UAH',
            methodId: 'TestMethodId',
            methodName: 'TestMethodName');

        verify(mockedHttpClient.post(
                Uri.parse('https://api.fondy.eu/api/checkout/ajax/mobile_pay'),
                body:
                    '{"request":{"currency":"UAH","amount":123,"merchant_id":100500}}',
                headers: REQUEST_HEADERS))
            .called(1);

        expect(config['payment_system'], 'TestPaymentSystem');
        expect(config['data'], 'SomeMethodTestData');
        expect(config['businessName'], 'TestBusinessName');
      });
    });

    group('token', () {
      test('should should throw exception with unknown methodId', () async {
        when(mockedHttpClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
                (_) async => http.Response(RESPONSE_GET_PAYMENT_CONFIG, 200));

        await expectLater(
            () => api.getPaymentConfig(
                token: 'SomeAlmostUniqueToken',
                methodId: 'TestMethodId404',
                methodName: 'TestMethodName404'),
            thrownUnsupported(
                'TestMethodName404 is not supported for token "SomeAlmostUniqueToken"'));
      });
      test('should proceed successfully', () async {
        when(mockedHttpClient.post(any,
                headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer(
                (_) async => http.Response(RESPONSE_GET_PAYMENT_CONFIG, 200));

        final config = await api.getPaymentConfig(
            token: 'SomeAlmostUniqueToken',
            methodId: 'TestMethodId',
            methodName: 'TestMethodName');

        verify(mockedHttpClient.post(
                Uri.parse('https://api.fondy.eu/api/checkout/ajax/mobile_pay'),
                body: '{"request":{"token":"SomeAlmostUniqueToken"}}',
                headers: REQUEST_HEADERS))
            .called(1);

        expect(config['payment_system'], 'TestPaymentSystem');
        expect(config['data'], 'SomeMethodTestData');
        expect(config['businessName'], 'TestBusinessName');
      });
    });
    test('throws api error', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_ERROR, 200));

      await expectLater(
          () => api.getPaymentConfig(
              token: 'SomeAlmostUniqueToken',
              methodId: 'TestMethodId',
              methodName: 'TestMethodName'),
          thrownCloudipspApiError(500111, 'ReqID44332211', 'SomeErrorMessage'));
    });
  });

  group('getToken', () {
    test('should proceed successfully with minimal required params', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_GET_TOKEN, 200));

      final token = await api.getToken(100500, order);

      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/token'),
              body:
                  '{"request":{"verification_type":"amount","merchant_data":"[]","order_id":"1234-45","merchant_id":"100500","required_rectoken":"N","preauth":"N","delayed":"N","currency":"UAH","amount":"123","verification":"N","response_url":"http://callback","order_desc":"Nice :)"}}',
              headers: REQUEST_HEADERS))
          .called(1);

      expect(token, 'JustCreatedToken');
    });
    test('should proceed successfully with all possible params', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_GET_TOKEN, 200));

      order.productId = 'SomeProductId';
      order.paymentSystems = 'SomePaymentSystems';
      order.defaultPaymentSystem = 'SomeDefaultPaymentSystem';
      order.lifetime = 22;
      order.merchantData = 'SomeMerchantData';
      order.version = '2.0.0';
      order.serverCallbackUrl = 'https://waitforcallback.com';
      order.reservationData = '0xFF';
      order.lang = Lang.uk;
      order.preauth = true;
      order.requiredRecToken = true;
      order.verification = true;
      order.delayed = true;

      final token = await api.getToken(100500, order);

      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/token'),
              body:
                  '{"request":{"verification_type":"amount","merchant_data":"SomeMerchantData","lifetime":22,"currency":"UAH","server_callback_url":"https://waitforcallback.com","product_id":"SomeProductId","response_url":"http://callback","order_desc":"Nice :)","payment_systems":"SomePaymentSystems","reservation_data":"0xFF","lang":"uk","version":"2.0.0","merchant_id":"100500","order_id":"1234-45","required_rectoken":"Y","preauth":"Y","delayed":"Y","amount":"123","verification":"Y","default_payment_system":"SomeDefaultPaymentSystem"}}',
              headers: REQUEST_HEADERS))
          .called(1);

      expect(token, 'JustCreatedToken');
    });
    test('throws api error', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_ERROR, 200));

      await expectLater(() => api.getToken(100500, order),
          thrownCloudipspApiError(500111, 'ReqID44332211', 'SomeErrorMessage'));
    });
  });

  group('getOrder', () {
    test('should proceed successfully and parse receipt as well', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_GET_ORDER, 200));

      final receipt = await api.getOrder('SomeMaybeUniqueToken');

      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/merchant/order'),
              body: '{"request":{"token":"SomeMaybeUniqueToken"}}',
              headers: REQUEST_HEADERS))
          .called(1);

      expect(receipt.maskedCard, '4444*6666');
      expect(receipt.cardBin, 4444);
      expect(receipt.amount, 100500);
      expect(receipt.paymentId, 500100);
      expect(receipt.currency, 'UAH');
      expect(receipt.status, Status.approved);
      expect(receipt.transactionType, TransactionType.purchase);
      expect(receipt.senderCellPhone, '');
      expect(receipt.cardType, CardType.MAESTRO);
      expect(receipt.rrn, '');
      expect(receipt.approvalCode, '');
      expect(receipt.responseCode, -1);
      expect(receipt.productId, 'productID');
      expect(receipt.recToken, null);
      expect(receipt.recTokenLifeTime, null);
      expect(receipt.reversalAmount, 0);
      expect(receipt.settlementAmount, 0);
      expect(receipt.settlementCurrency, null);
      expect(receipt.settlementDate, null);
      expect(receipt.eci, 1);
      expect(receipt.fee, 2);
      expect(receipt.actualAmount, 3);
      expect(receipt.actualCurrency, 'UAH');
      expect(receipt.paymentSystem, 'test');
      expect(receipt.verificationStatus, null);
      expect(receipt.signature, 'Sign');
      expect(receipt.responseUrl, 'http://callback');
    });
    test('throws api error', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_ERROR, 200));

      await expectLater(() => api.getOrder('SomeMaybeUniqueToken'),
          thrownCloudipspApiError(500111, 'ReqID44332211', 'SomeErrorMessage'));
    });
  });

  group('checkout', () {
    test('should proceed successfully without email', () async {
      final creditCard = PrivateCreditCard('4444555511116666', 11, 25, '111');
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_CHECKOUT, 200));

      final result =
          await api.checkout(creditCard, 'Token', null, 'http://callback.url');
      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/ajax'),
              body:
                  '{"request":{"payment_system":"card","token":"Token","expiry_date":"1125","cvv2":"111","card_number":"4444555511116666"}}',
              headers: REQUEST_HEADERS))
          .called(1);
      expect(result['someUniqueField'], 'someUniqueValueWhichPassesTheTest');
    });
    test('should proceed successfully with email', () async {
      final creditCard = PrivateCreditCard('4444555511116666', 1, 25, '111');
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_CHECKOUT, 200));

      final result = await api.checkout(
          creditCard, 'Token', 'example@test.com', 'http://callback.url');
      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/ajax'),
              body:
                  '{"request":{"email":"example@test.com","payment_system":"card","token":"Token","expiry_date":"0125","cvv2":"111","card_number":"4444555511116666"}}',
              headers: REQUEST_HEADERS))
          .called(1);
      expect(result['someUniqueField'], 'someUniqueValueWhichPassesTheTest');
    });
    test('throws api error', () async {
      final creditCard = PrivateCreditCard('4444555511116666', 1, 25, '111');
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_ERROR, 200));

      await expectLater(
          () => api.checkout(
              creditCard, 'Token', 'example@test.com', 'http://callback.url'),
          thrownCloudipspApiError(500111, 'ReqID44332211', 'SomeErrorMessage'));
    });
  });

  group('checkoutNativePay', () {
    final someNativeData = {'someField': 'whichRepresentsNativeData'};
    test('should proceed successfully without email', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_CHECKOUT, 200));

      final result = await api.checkoutNativePay(
          'Token', null, 'SuperPaymentSystem', someNativeData);
      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/ajax'),
              body:
                  '{"request":{"payment_system":"SuperPaymentSystem","data":{"someField":"whichRepresentsNativeData"},"token":"Token"}}',
              headers: REQUEST_HEADERS))
          .called(1);
      expect(result['someUniqueField'], 'someUniqueValueWhichPassesTheTest');
    });
    test('should proceed successfully with email', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_CHECKOUT, 200));

      final result = await api.checkoutNativePay(
          'Token', 'example@test.com', 'SuperPaymentSystem', someNativeData);
      verify(mockedHttpClient.post(
              Uri.parse('https://api.fondy.eu/api/checkout/ajax'),
              body:
                  '{"request":{"email":"example@test.com","payment_system":"SuperPaymentSystem","data":{"someField":"whichRepresentsNativeData"},"token":"Token"}}',
              headers: REQUEST_HEADERS))
          .called(1);
      expect(result['someUniqueField'], 'someUniqueValueWhichPassesTheTest');
    });

    test('throws api error', () async {
      when(mockedHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(RESPONSE_ERROR, 200));

      await expectLater(
          () => api.checkoutNativePay('Token', 'example@test.com',
              'SuperPaymentSystem', someNativeData),
          thrownCloudipspApiError(500111, 'ReqID44332211', 'SomeErrorMessage'));
    });
  });

  test('call3ds', () async {
    when(mockedHttpClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('Anything', 200));

    final response = await api.call3ds(
        'https://urltocheck.com', 'SomeBody', 'application/whoknows');

    verify(mockedHttpClient.post(Uri.parse('https://urltocheck.com'),
            body: 'SomeBody', headers: REQUEST_HEADERS_3DS))
        .called(1);
    expect(response.body, 'Anything');
  });
}

const RESPONSE_GET_PAYMENT_CONFIG = '''
{
  "response": {
    "methods": [
      {
        "supportedMethods": "TestMethodId",
        "data": "SomeMethodTestData"
      }
    ],
    "payment_system": "TestPaymentSystem",
    "details": {
      "total": {
        "label": "TestBusinessName"
      }
    }
  }
}
''';

const RESPONSE_GET_TOKEN = '''
{
  "response": {
    "token": "JustCreatedToken"
  }
}
''';

const RESPONSE_GET_ORDER = '''
{
  "response": {
    "order_data": {
      "masked_card": "4444*6666",
      "card_bin": 4444,
      "amount": "100500",
      "payment_id": 500100,
      "currency": "UAH",
      "order_status": "approved",
      "tran_type": "purchase",
      "sender_cell_phone": "",
      "sender_account": "",
      "card_type": "MAESTRO",
      "rrn": "",
      "approval_code": "",
      "response_code": -1,
      "product_id": "productID",
      "rectoken": null,
      "rectoken_lifetime": null,
      "reversal_amount": "0",
      "settlement_amount": "0",
      "settlement_currency": null,
      "settlement_date": null,
      "eci": "1",
      "fee": "2",
      "actual_amount": "3",
      "actual_currency": "UAH",
      "payment_system": "test",
      "verification_status": null,
      "signature": "Sign"
    },
    "response_url": "http://callback"
  }
}
''';

const RESPONSE_CHECKOUT = '''
{
  "response": {
    "someUniqueField": "someUniqueValueWhichPassesTheTest"
  }
}
''';

const RESPONSE_ERROR = '''
{
  "response": {
    "error_message": "SomeErrorMessage",
    "error_code": 500111,
    "request_id": "ReqID44332211"
  }
}
''';

const REQUEST_HEADERS = {
  'User-Agent': 'Flutter',
  'SDK-OS': 'UnitTestOS',
  'SDK-Version': '0.0.1',
  'Accept': 'application/json',
  'Content-Type': 'application/json'
};
const REQUEST_HEADERS_3DS = {
  'User-Agent': 'Flutter',
  'SDK-OS': 'UnitTestOS',
  'SDK-Version': '0.0.1',
  'Content-Type': 'application/whoknows'
};
