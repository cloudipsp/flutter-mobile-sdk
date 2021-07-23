import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import './api.dart';
import './cloudipsp_error.dart';
import './cloudipsp_web_view_confirmation.dart';
import './credit_card.dart';
import './native.dart';
import './order.dart';
import './platform_specific.dart';
import './receipt.dart';

typedef void CloudipspWebViewHolder(CloudipspWebViewConfirmation confirmation);

abstract class Cloudipsp {
  factory Cloudipsp(
          int merchantId, CloudipspWebViewHolder cloudipspWebViewHolder) =
      CloudipspImpl;

  int get merchantId;

  Future<bool> supportsApplePay();

  Future<bool> supportsGooglePay();

  Future<String> getToken(Order order);

  Future<Receipt> pay(CreditCard creditCard, Order order);

  Future<Receipt> payToken(CreditCard card, String token);

  Future<Receipt> applePay(Order order);

  Future<Receipt> applePayToken(String token);

  Future<Receipt> googlePay(Order order);

  Future<Receipt> googlePayToken(String token);
}

class CloudipspImpl implements Cloudipsp {
  final int merchantId;
  CloudipspWebViewHolder _cloudipspWebViewHolder;
  final Api _api;
  final Native _native;
  final PlatformSpecific _platformSpecific;

  CloudipspImpl(this.merchantId, CloudipspWebViewHolder cloudipspWebViewHolder)
      : _api = Api(PlatformSpecific()),
        _native = Native(),
        _platformSpecific = PlatformSpecific() {
    if (!(merchantId > 0)) {
      throw ArgumentError.value(merchantId, 'merchantId');
    }
    if (cloudipspWebViewHolder == null) {
      throw ArgumentError.notNull('cloudipspWebViewHolder');
    }
    _cloudipspWebViewHolder = cloudipspWebViewHolder;
  }

  CloudipspImpl.withMocks({
    this.merchantId,
    CloudipspWebViewHolder cloudipspWebViewHolder,
    Api api,
    Native native,
    PlatformSpecific platformSpecific,
  })  : _api = api,
        _native = native,
        _platformSpecific = platformSpecific,
        _cloudipspWebViewHolder = cloudipspWebViewHolder;

  Future<bool> supportsApplePay() async {
    if (!_platformSpecific.isIOS) {
      return false;
    }
    return _native.supportsApplePay();
  }

  Future<bool> supportsGooglePay() async {
    if (!_platformSpecific.isAndroid) {
      return false;
    }
    return _native.supportsGooglePay();
  }

  _assertApplePay() {
    if (!_platformSpecific.isIOS) {
      throw UnsupportedError('ApplePay available only for iOS');
    }
  }

  _assertGooglePay() {
    if (!_platformSpecific.isAndroid) {
      throw UnsupportedError('GooglePay available only for Android');
    }
  }

  @override
  Future<String> getToken(Order order) {
    if (order == null) {
      throw ArgumentError.notNull("order");
    }
    return _api.getToken(merchantId, order);
  }

  @override
  Future<Receipt> pay(CreditCard card, Order order) async {
    if (card == null) {
      throw ArgumentError.notNull("card");
    }
    if (!card.isValid() || !(card is PrivateCreditCard)) {
      throw ArgumentError("CreditCard is not valid");
    }
    if (order == null) {
      throw ArgumentError.notNull("order");
    }
    final privateCard = card as PrivateCreditCard;
    final token = await _api.getToken(merchantId, order);
    final checkoutResponse =
        await _api.checkout(privateCard, token, order.email, Api.URL_CALLBACK);
    return _payContinue(checkoutResponse, token, Api.URL_CALLBACK);
  }

  @override
  Future<Receipt> payToken(CreditCard card, String token) async {
    if (card == null) {
      throw ArgumentError.notNull("card");
    }
    if (!card.isValid() || !(card is PrivateCreditCard)) {
      throw ArgumentError("CreditCard is not valid");
    }
    if (token == null) {
      throw ArgumentError.notNull("token");
    }
    final privateCard = card as PrivateCreditCard;
    final order = await _api.getOrder(token);
    final checkoutResponse =
        await _api.checkout(privateCard, token, null, order.responseUrl);
    return await _payContinue(checkoutResponse, token, Api.URL_CALLBACK);
  }

  @override
  Future<Receipt> applePay(Order order) async {
    _assertApplePay();
    if (order == null) {
      throw ArgumentError.notNull("order");
    }
    final config = await _api.getPaymentConfig(
      merchantId: merchantId,
      amount: order.amount,
      currency: order.currency,
      methodId: 'https://apple.com/apple-pay',
      methodName: 'ApplePay',
    );
    dynamic applePayInfo;
    try {
      applePayInfo = await _native.applePay(
          config, order.amount, order.currency, order.description);
    } on PlatformException catch (e) {
      throw CloudipspUserError(e.code, e.message);
    }

    try {
      final token = await _api.getToken(merchantId, order);
      final checkout = await _api.checkoutNativePay(
          token, order.email, config['payment_system'], applePayInfo);
      final receipt = await _payContinue(checkout, token, Api.URL_CALLBACK);
      await _native.applePayComplete(true);
      return receipt;
    } catch (e) {
      _native.applePayComplete(false);
      throw e;
    }
  }

  @override
  Future<Receipt> applePayToken(String token) async {
    _assertApplePay();
    if (token == null) {
      throw ArgumentError.notNull("token");
    }
    final config = await _api.getPaymentConfig(
      token: token,
      methodId: 'https://apple.com/apple-pay',
      methodName: 'ApplePay',
    );

    final order = await _api.getOrder(token);
    dynamic applePayInfo;
    try {
      applePayInfo =
          await _native.applePay(config, order.amount, order.currency, ' ');
    } on PlatformException catch (e) {
      throw CloudipspUserError(e.code, e.message);
    }

    try {
      final checkout = await _api.checkoutNativePay(
          token, null, config['payment_system'], applePayInfo);
      final receipt = await _payContinue(checkout, token, order.responseUrl);
      await _native.applePayComplete(true);
      return receipt;
    } catch (e) {
      _native.applePayComplete(false);
      throw e;
    }
  }

  @override
  Future<Receipt> googlePay(Order order) async {
    _assertGooglePay();
    if (order == null) {
      throw ArgumentError.notNull("order");
    }

    final config = await _api.getPaymentConfig(
      merchantId: merchantId,
      amount: order.amount,
      currency: order.currency,
      methodId: 'https://google.com/pay',
      methodName: 'GooglePay',
    );
    dynamic googlePayInfo;
    try {
      googlePayInfo = await _native.googlePay(config['data']);
    } on PlatformException catch (e) {
      throw CloudipspUserError(e.code, e.message);
    }

    final token = await _api.getToken(merchantId, order);
    final checkout = await _api.checkoutNativePay(
        token, order.email, config['payment_system'], googlePayInfo);
    return _payContinue(checkout, token, Api.URL_CALLBACK);
  }

  @override
  Future<Receipt> googlePayToken(String token) async {
    _assertGooglePay();
    if (token == null) {
      throw ArgumentError.notNull("token");
    }
    final order = await _api.getOrder(token);
    final config = await _api.getPaymentConfig(
      token: token,
      methodId: 'https://google.com/pay',
      methodName: 'GooglePay',
    );
    dynamic googlePayInfo;
    try {
      googlePayInfo = await _native.googlePay(config['data']);
    } on PlatformException catch (e) {
      throw CloudipspUserError(e.code, e.message);
    }

    final checkout = await _api.checkoutNativePay(
        token, null, config['payment_system'], googlePayInfo);
    return _payContinue(checkout, token, order.responseUrl);
  }

  Future<Receipt> _payContinue(
      dynamic checkoutResponse, String token, String callbackUrl) async {
    final url = checkoutResponse['url'] as String;
    if (!url.startsWith(callbackUrl)) {
      final receipt = await _threeDS(url, checkoutResponse, callbackUrl);
      if (receipt != null) {
        return receipt;
      }
    }
    return _api.getOrder(token);
  }

  Future<Receipt> _threeDS(
      String url, dynamic checkoutResponse, String callbackUrl) async {
    String body;
    String contentType;

    final sendData = checkoutResponse['send_data'] as Map<String, dynamic>;
    if (sendData['PaReq'] == '') {
      body = jsonEncode(sendData);
      contentType = 'application/json';
    } else {
      body = 'MD=' +
          Uri.encodeComponent(sendData['MD']) +
          '&PaReq=' +
          Uri.encodeComponent(sendData['PaReq']) +
          '&TermUrl=' +
          Uri.encodeComponent(sendData['TermUrl']);
      contentType = 'application/x-www-form-urlencoded';
    }

    final response = await _api.call3ds(url, body, contentType);
    final completer = new Completer<Receipt>();
    _cloudipspWebViewHolder(PrivateCloudipspWebViewConfirmation(
        Api.API_HOST, url, callbackUrl, response, completer));
    return completer.future;
  }
}
