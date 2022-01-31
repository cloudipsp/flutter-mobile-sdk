import 'package:flutter/services.dart';

class Native {
  static const MethodChannel _CHANNEL = const MethodChannel('cloudipsp_mobile');

  final MethodChannel _channel;

  Native.withChannel(this._channel);

  Native() : this.withChannel(_CHANNEL);

  Future<bool> supportsApplePay() async {
    final result = await _channel.invokeMethod('supportsApplePay');
    return result as bool;
  }

  Future<bool> supportsGooglePay() async {
    final result = await _channel.invokeMethod('supportsGooglePay');
    return result as bool;
  }

  Future<dynamic> applePay(
      dynamic config, int amount, String currency, String description) {
    return _channel.invokeMethod('applePay', {
      'config': config,
      'amount': amount,
      'currency': currency,
      'about': description,
    });
  }

  Future<dynamic> applePayComplete(bool success) {
    return _channel.invokeMethod('applePayComplete', {'success': success});
  }

  Future<dynamic> googlePay(dynamic configData) {
    return _channel.invokeMethod('googlePay', configData);
  }

  Future<void> androidAddCookie(String url, String cookie) {
    return _channel.invokeMethod('setCookie', {'url': url, 'cookie': cookie});
  }
}
