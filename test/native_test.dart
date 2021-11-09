import 'package:cloudipsp_mobile/src/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late Native native;
  MockedMethodChannel? mockedMethodChannel;

  setUp(() {
    mockedMethodChannel = MockedMethodChannel();
    native = Native.withChannel(mockedMethodChannel);
  });

  test('supportsApplePay invokes via channel', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => true);
    final result = await native.supportsApplePay();
    verify(mockedMethodChannel!.invokeMethod('supportsApplePay')).called(1);
    expect(result, true);
  });

  test('supportsGooglePay invokes via channel', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => false);
    final result = await native.supportsGooglePay();
    verify(mockedMethodChannel!.invokeMethod('supportsGooglePay')).called(1);
    expect(result, false);
  });

  test('applePay invokes via channel with right params', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => 'SomeResult');
    final config = {'someKey': 'someValue'};
    final result = await native.applePay(config, 100500, 'USD', 'testMock');
    verify(mockedMethodChannel!.invokeMethod('applePay', {
      'config': config,
      'amount': 100500,
      'currency': 'USD',
      'about': 'testMock'
    })).called(1);
    expect(result, 'SomeResult');
  });

  test('applePayComplete invokes via channel with true', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => 'SomeResultAboutComplete');
    final result = await native.applePayComplete(true);
    verify(mockedMethodChannel!
        .invokeMethod('applePayComplete', {'success': true})).called(1);
    expect(result, 'SomeResultAboutComplete');
  });

  test('applePayComplete invokes via channel with false', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => 'SomeResultAboutCompleteFalse');
    final result = await native.applePayComplete(false);
    verify(mockedMethodChannel!
        .invokeMethod('applePayComplete', {'success': false})).called(1);
    expect(result, 'SomeResultAboutCompleteFalse');
  });

  test('googlePay invokes via channel with right params', () async {
    when(mockedMethodChannel!.invokeMethod(any!, any))
        .thenAnswer((_) async => 'SomeResultAboutGooglePay');
    final config = {'someKey': 'someValue'};
    final result = await native.googlePay(config);
    verify(mockedMethodChannel!.invokeMethod('googlePay', config)).called(1);
    expect(result, 'SomeResultAboutGooglePay');
  });
}

class MockedMethodChannel extends Mock implements MethodChannel {}
