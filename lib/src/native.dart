import 'package:flutter/services.dart';

class Native {
  static const MethodChannel _CHANNEL = const MethodChannel('cloudipsp_mobile');

  final MethodChannel? _channel;

  Native.withChannel(this._channel);

  Native() : this.withChannel(_CHANNEL);

  Future<bool?> supportsApplePay() {
    return _channel!.invokeMethod('supportsApplePay');
  }

  Future<bool?> supportsGooglePay() {
    return _channel!.invokeMethod('supportsGooglePay');
  }

  Future<dynamic> applePay(
      dynamic config, int amount, String? currency, String? description) {
    return _channel!.invokeMethod('applePay', {
      'config': config,
      'amount': amount,
      'currency': currency,
      'about': description,
    });
  }

  Future<dynamic> applePayComplete(bool success) {
    return _channel!.invokeMethod('applePayComplete', {'success': success});
  }

  Future<dynamic> googlePay(dynamic configData) {
    return _channel!.invokeMethod('googlePay', configData);
  }
}
