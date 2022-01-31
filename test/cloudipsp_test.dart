import 'package:cloudipsp_mobile/src/credit_card.dart';
import 'package:cloudipsp_mobile/src/native.dart';
import 'package:cloudipsp_mobile/src/platform_specific.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/api.dart';
import 'package:cloudipsp_mobile/src/cloudipsp.dart';
import 'package:cloudipsp_mobile/src/cloudipsp_web_view_confirmation.dart';

import './cloudipsp_test.mocks.dart';
import './utils.dart';

@GenerateMocks([Api, Native, PlatformSpecific])
void main() {
  group('constructor', () {
    test('should throw exception with wrong merchantId', () {
      expect(
          () => Cloudipsp(-1, (CloudipspWebViewConfirmation confirmation) {}),
          thrownArgumentErrorValue(-1, 'merchantId'));
    });
    test('should create new instance', () {
      final c = Cloudipsp(1, (CloudipspWebViewConfirmation confirmation) {});
      expect(c.merchantId, 1);
    });
  });

  group('methods', () {
    late MockApi mockedApi;
    late MockNative mockedNative;
    late MockPlatformSpecific mockedPlatformSpecific;
    late GenericMocks genericMocks;
    late Cloudipsp cloudipsp;

    final someToken = 'SomeToken';
    final cardSuccessNormal =
        PrivateCreditCard('4444555511116666', 11, 25, '111');
    final cardSuccess3DSCase1 =
        PrivateCreditCard('4444555566661111', 11, 25, '111');
    final cardSuccess3DSCase2 =
        PrivateCreditCard('4444555566661111', 11, 25, '112');
    // final cardFailureNormal =
    // PrivateCreditCard('4444111155556666', 11, 25, '111');
    // final cardFailure3DS = PrivateCreditCard('4444111166665555', 11, 25, '111');
    final cardInvalid = PrivateCreditCard('4444555566661110', 11, 25, '111');
    final order = Order(123, 'UAH', '1234-45', 'Nice :)', 'example@test.com');
    final receipt = Receipt(
        '4444*6666',
        4444,
        100500,
        500100,
        'UAH',
        Status.approved,
        TransactionType.purchase,
        '',
        '',
        CardType.UNKNOWN,
        '',
        '',
        -1,
        'productID',
        null,
        null,
        0,
        0,
        null,
        null,
        1,
        2,
        3,
        'UAH',
        'test',
        null,
        'Sign',
        '');
    final applePayConfig = {'payment_system': 'MockApplePayPaymentSystem'};
    final applePayInfo = 'ApplePayInfo_Mocked123';
    final googlePayConfig = {
      'data': 'MockGooglePayData',
      'payment_system': 'MockGooglePayPaymentSystem'
    };
    final googlePayInfo = 'GooglePayInfo_Mocked123';

    setUp(() {
      mockedApi = MockApi();
      mockedNative = MockNative();
      mockedPlatformSpecific = MockPlatformSpecific();
      genericMocks = GenericMocks();

      cloudipsp = CloudipspImpl.withMocks(
          merchantId: 100500,
          cloudipspWebViewHolder: genericMocks.cloudipspWebViewHolder,
          api: mockedApi,
          native: mockedNative,
          platformSpecific: mockedPlatformSpecific);

      when(mockedApi.getToken(any, any)).thenAnswer((_) async => someToken);
      when(mockedApi.checkout(cardSuccessNormal, any, any, any))
          .thenAnswer((_) async => {'url': Api.URL_CALLBACK});
      when(mockedApi.checkout(cardSuccess3DSCase1, any, any, any))
          .thenAnswer((_) async => {
                'url': 'https://fake3dscase1.url',
                'send_data': {
                  'PaReq': 'SomePaReq UrlEncoded',
                  'MD': 'SomeMD Case1',
                  'TermUrl': 'SomeTermUrl Case1',
                },
              });
      when(mockedApi.checkout(cardSuccess3DSCase2, any, any, any))
          .thenAnswer((_) async => {
                'url': 'https://fake3dscase2.url',
                'send_data': {
                  'PaReq': '',
                  'MD': 'SomeMDC_Case2',
                  'TermUrl': 'SomeTermUrl_Case2',
                },
              });
      when(mockedApi.getOrder(someToken)).thenAnswer((_) async => receipt);
      when(mockedApi.call3ds(any, any, any))
          .thenAnswer((_) async => http.Response('', 200));
      when(mockedApi.getPaymentConfig(
              token: anyNamed('token'),
              merchantId: anyNamed('merchantId'),
              amount: anyNamed('amount'),
              currency: anyNamed('currency'),
              methodId: 'https://apple.com/apple-pay',
              methodName: 'ApplePay'))
          .thenAnswer((_) async => applePayConfig);
      when(mockedApi.getPaymentConfig(
              token: anyNamed('token'),
              merchantId: anyNamed('merchantId'),
              amount: anyNamed('amount'),
              currency: anyNamed('currency'),
              methodId: 'https://google.com/pay',
              methodName: 'GooglePay'))
          .thenAnswer((_) async => googlePayConfig);

      when(mockedNative.applePay(any, any, any, any))
          .thenAnswer((_) async => applePayInfo);
      when(mockedNative.applePayComplete(any)).thenAnswer((_) async => 0);
      when(mockedNative.googlePay(any)).thenAnswer((_) async => googlePayInfo);

      when(mockedApi.checkoutNativePay(any, any, any, any))
          .thenAnswer((_) async => {'url': Api.URL_CALLBACK});
    });

    group('supportsApplePay', () {
      test('should not support ApplePay non iOS platform', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(false);
        expect(await cloudipsp.supportsApplePay(), false);
      });

      test('should not support ApplePay by native', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedNative.supportsApplePay()).thenAnswer((_) async => false);
        expect(await cloudipsp.supportsApplePay(), false);
      });

      test('should support ApplePay', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedNative.supportsApplePay()).thenAnswer((_) async => true);
        expect(await cloudipsp.supportsApplePay(), true);
      });
    });

    group('supportsGooglePay', () {
      test('should not support GooglePay non android platform', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(false);
        expect(await cloudipsp.supportsGooglePay(), false);
      });

      test('should not support GooglePay by native', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        when(mockedNative.supportsGooglePay()).thenAnswer((_) async => false);
        expect(await cloudipsp.supportsGooglePay(), false);
      });

      test('should support GooglePay', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        when(mockedNative.supportsGooglePay()).thenAnswer((_) async => true);
        expect(await cloudipsp.supportsGooglePay(), true);
      });
    });

    group('getToken', () {
      test('should successfully provide token', () async {
        final receivedToken = await cloudipsp.getToken(order);
        expect(receivedToken, someToken);
        verify(mockedApi.getToken(cloudipsp.merchantId, order)).called(1);
      });
    });

    group('pay', () {
      test('should throw exception with invalid credit card', () {
        expect(() => cloudipsp.pay(cardInvalid, order),
            thrownArgumentError('CreditCard is not valid'));
      });
      test('should pay with normal successful card', () async {
        final receivedReceipt = await cloudipsp.pay(cardSuccessNormal, order);
        expect(receivedReceipt, receipt);
      });
      group('3DS', () {
        PrivateCloudipspWebViewConfirmation confirmation;
        setUp(() {
          when(genericMocks.cloudipspWebViewHolder(any)).thenAnswer((call) {
            confirmation = call.positionalArguments[0]
                as PrivateCloudipspWebViewConfirmation;
            confirmation.completer.complete(null);
          });
        });

        test('should pay with 3DS card case1', () async {
          final receivedReceipt =
              await cloudipsp.pay(cardSuccess3DSCase1, order);
          verify(mockedApi.call3ds(
                  'https://fake3dscase1.url',
                  'MD=SomeMD%20Case1&PaReq=SomePaReq%20UrlEncoded&TermUrl=SomeTermUrl%20Case1',
                  'application/x-www-form-urlencoded'))
              .called(1);
          expect(receivedReceipt, receipt);
        });
        test('should pay with 3DS card case2', () async {
          final receivedReceipt =
              await cloudipsp.pay(cardSuccess3DSCase2, order);
          verify(mockedApi.call3ds(
                  'https://fake3dscase2.url',
                  '{"PaReq":"","MD":"SomeMDC_Case2","TermUrl":"SomeTermUrl_Case2"}',
                  'application/json'))
              .called(1);
          expect(receivedReceipt, receipt);
        });
      });
    });

    group('payToken', () {
      test('should throw exception with invalid credit card', () {
        expect(() => cloudipsp.payToken(cardInvalid, someToken),
            thrownArgumentError('CreditCard is not valid'));
      });
      test('should successfully pay', () async {
        final receivedReceipt =
            await cloudipsp.payToken(cardSuccessNormal, someToken);
        expect(receivedReceipt, receipt);
      });
    });

    group('applePay', () {
      test('should throw exception on non iOS platforms', () {
        when(mockedPlatformSpecific.isIOS).thenReturn(false);
        expect(() => cloudipsp.applePay(order),
            thrownUnsupported('ApplePay available only for iOS'));
      });
      test('should handle native exception', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedNative.applePay(any, any, any, any)).thenAnswer((_) async =>
            throw PlatformException(
                code: 'applePay_MOCK_CODE', message: 'applePay_MOCK_MESSAGE'));
        expect(
            () => cloudipsp.applePay(order),
            thrownCloudipspUserError(
                'applePay_MOCK_CODE', 'applePay_MOCK_MESSAGE'));
      });
      test('should notify native about api failure and throw error', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedApi.checkoutNativePay(any, any, any, any)).thenAnswer(
            (_) async =>
                throw CloudipspApiError(100500, 'reqID_123', 'Whoops'));
        await expectLater(() => cloudipsp.applePay(order),
            thrownCloudipspApiError(100500, 'reqID_123', 'Whoops'));
        verify(mockedNative.applePayComplete(false)).called(1);
      });
      test('should successfully pay', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        final receivedReceipt = await cloudipsp.applePay(order);

        verify(mockedNative.applePay(applePayConfig, order.amount,
                order.currency, order.description))
            .called(1);
        verify(mockedApi.checkoutNativePay(someToken, order.email,
                applePayConfig['payment_system'], applePayInfo))
            .called(1);
        verify(mockedNative.applePayComplete(true)).called(1);

        expect(receivedReceipt, receipt);
      });
    });

    group('applePayToken', () {
      test('should throw exception on non iOS platforms', () {
        when(mockedPlatformSpecific.isIOS).thenReturn(false);
        expect(() => cloudipsp.applePayToken(someToken),
            thrownUnsupported('ApplePay available only for iOS'));
      });
      test('should handle native exception', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedNative.applePay(any, any, any, any)).thenAnswer((_) async =>
            throw PlatformException(
                code: 'applePayToken_MOCK_CODE',
                message: 'applePayToken_MOCK_MESSAGE'));
        expect(
            () => cloudipsp.applePayToken(someToken),
            thrownCloudipspUserError(
                'applePayToken_MOCK_CODE', 'applePayToken_MOCK_MESSAGE'));
      });
      test('should notify native about api failure and throw error', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        when(mockedApi.checkoutNativePay(any, any, any, any)).thenAnswer(
            (_) async =>
                throw CloudipspApiError(100500, 'reqID_123', 'Whoops'));
        await expectLater(() => cloudipsp.applePayToken(someToken),
            thrownCloudipspApiError(100500, 'reqID_123', 'Whoops'));
        verify(mockedNative.applePayComplete(false)).called(1);
      });
      test('should successfully pay', () async {
        when(mockedPlatformSpecific.isIOS).thenReturn(true);
        final receivedReceipt = await cloudipsp.applePayToken(someToken);

        verify(mockedNative.applePay(
                applePayConfig, receipt.amount, receipt.currency, ' '))
            .called(1);
        verify(mockedApi.checkoutNativePay(someToken, null,
                applePayConfig['payment_system'], applePayInfo))
            .called(1);
        verify(mockedNative.applePayComplete(true)).called(1);

        expect(receivedReceipt, receipt);
      });
    });

    group('googlePay', () {
      test('should throw exception on non android platforms', () {
        when(mockedPlatformSpecific.isAndroid).thenReturn(false);
        expect(() => cloudipsp.googlePay(order),
            thrownUnsupported('GooglePay available only for Android'));
      });
      test('should handle native exception', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        when(mockedNative.googlePay(any)).thenAnswer((_) async =>
            throw PlatformException(
                code: 'googlePay_MOCK_CODE',
                message: 'googlePay_MOCK_MESSAGE'));
        expect(
            () => cloudipsp.googlePay(order),
            thrownCloudipspUserError(
                'googlePay_MOCK_CODE', 'googlePay_MOCK_MESSAGE'));
      });
      test('should successfully pay', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        final receivedReceipt = await cloudipsp.googlePay(order);

        verify(mockedNative.googlePay(googlePayConfig['data'])).called(1);
        verify(mockedApi.checkoutNativePay(someToken, order.email,
                googlePayConfig['payment_system'], googlePayInfo))
            .called(1);

        expect(receivedReceipt, receipt);
      });
    });

    group('googlePayToken', () {
      test('should throw exception on non android platforms', () {
        when(mockedPlatformSpecific.isAndroid).thenReturn(false);
        expect(() => cloudipsp.googlePayToken(someToken),
            thrownUnsupported('GooglePay available only for Android'));
      });
      test('should handle native exception', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        when(mockedNative.googlePay(any)).thenAnswer((_) async =>
            throw PlatformException(
                code: 'googlePayToken_MOCK_CODE',
                message: 'googlePayToken_MOCK_MESSAGE'));
        expect(
            () => cloudipsp.googlePayToken(someToken),
            thrownCloudipspUserError(
                'googlePayToken_MOCK_CODE', 'googlePayToken_MOCK_MESSAGE'));
      });
      test('should successfully pay', () async {
        when(mockedPlatformSpecific.isAndroid).thenReturn(true);
        final receivedReceipt = await cloudipsp.googlePayToken(someToken);

        verify(mockedNative.googlePay(googlePayConfig['data'])).called(1);
        verify(mockedApi.checkoutNativePay(someToken, null,
                googlePayConfig['payment_system'], googlePayInfo))
            .called(1);

        expect(receivedReceipt, receipt);
      });
    });
  });
}

class GenericMocks extends Mock {
  void cloudipspWebViewHolder(CloudipspWebViewConfirmation? confirmation);
}
