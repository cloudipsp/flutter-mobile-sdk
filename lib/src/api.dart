import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:cloudipsp_mobile/src/platform_specific.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cloudipsp_error.dart';
import './credit_card.dart';
import './order.dart';
import './receipt.dart';

class Api {
  static const API_HOST = 'https://api.fondy.eu';
  static const URL_CALLBACK = 'http://callback';

  final bool _logging;
  final http.Client _httpClient;
  final PlatformSpecific _platformSpecific;

  Api.withHttpClient(this._platformSpecific, this._httpClient, this._logging);

  Api(PlatformSpecific platformSpecific)
      : this.withHttpClient(platformSpecific, http.Client(), kDebugMode);

  Future<dynamic> getPaymentConfig(
      {String? token,
      int? merchantId,
      int? amount,
      String? currency,
      String? methodId,
      String? methodName}) async {
    final Map<String, dynamic> request = HashMap();
    if (token != null) {
      request['token'] = token;
    } else {
      request['merchant_id'] = merchantId;
      request['amount'] = amount;
      request['currency'] = currency;
    }
    final response = await _call('api/checkout/ajax/mobile_pay', request);

    dynamic data;

    final methods = response['methods'];
    for (int i = 0; i < methods.length; ++i) {
      final method = methods[i];
      if (method['supportedMethods'] == methodId) {
        data = method['data'];
        break;
      }
    }
    if (data == null) {
      if (token != null) {
        throw UnsupportedError(
            '$methodName is not supported for token "$token"');
      } else {
        throw UnsupportedError(
            '$methodName is not supported for merchant $merchantId and currency $currency');
      }
    }
    final totalDetails = response['details']['total'];

    return {
      'payment_system': response['payment_system'],
      'data': data,
      'businessName': totalDetails['label'],
    };
  }

  Future<String> getToken(int merchantId, Order order) async {
    final Map<String, dynamic> request = HashMap();
    request['order_id'] = order.id;
    request['merchant_id'] = merchantId.toString();
    request['order_desc'] = order.description;
    request['amount'] = order.amount.toString();
    request['currency'] = order.currency;
    if (order.productId != null && order.productId!.isNotEmpty) {
      request['product_id'] = order.productId;
    }
    if (order.paymentSystems != null && order.paymentSystems!.isNotEmpty) {
      request['payment_systems'] = order.paymentSystems;
    }
    if (order.defaultPaymentSystem != null &&
        order.defaultPaymentSystem!.isNotEmpty) {
      request['default_payment_system'] = order.defaultPaymentSystem;
    }
    if (order.lifetime != -1) {
      request['lifetime'] = order.lifetime;
    }
    if (order.merchantData == null || order.merchantData!.isEmpty) {
      request['merchant_data'] = '[]';
    } else {
      request['merchant_data'] = order.merchantData;
    }
    if (order.version != null && order.version!.isNotEmpty) {
      request['version'] = order.version;
    }
    if (order.serverCallbackUrl != null &&
        order.serverCallbackUrl!.isNotEmpty) {
      request['server_callback_url'] = order.serverCallbackUrl;
    }
    if (order.reservationData != null && order.reservationData!.isNotEmpty) {
      request['reservation_data'] = order.reservationData;
    }
    if (order.lang != null) {
      request['lang'] = describeEnum(order.lang!);
    }
    request['preauth'] = order.preauth ? 'Y' : 'N';
    request['required_rectoken'] = order.requiredRecToken ? 'Y' : 'N';
    request['verification'] = order.verification ? 'Y' : 'N';
    request['verification_type'] = describeEnum(order.verificationType);

    request.addAll(order.arguments);
    request['response_url'] = URL_CALLBACK;
    request['delayed'] = order.delayed ? 'Y' : 'N';

    final response = await _call('api/checkout/token', request);
    final String token = response['token'];
    return token;
  }

  Future<Receipt> getOrder(String token) async {
    final response =
        await _call('api/checkout/merchant/order', {'token': token});
    final receipt =
        Receipt.fromJson(response['order_data'], response['response_url']);
    if (receipt == null) {
      throw CloudipspError('Unable to parse receipt');
    }
    return receipt;
  }

  Future<dynamic> checkout(PrivateCreditCard creditCard, String token,
      String? email, String callbackUrl) {
    final Map<String, dynamic> request = HashMap();
    request['card_number'] = creditCard.cardNumber;
    request['expiry_date'] =
        _expMmFormat(creditCard.mm) + creditCard.yy.toString();
    request['cvv2'] = creditCard.cvv.toString();
    request['payment_system'] = 'card';
    request['token'] = token;
    if (email != null && email.isNotEmpty) {
      request['email'] = email;
    }
    return _call('api/checkout/ajax', request);
  }

  Future<dynamic> checkoutNativePay(
      String token, String? email, String paymentSystem, dynamic data) {
    final Map<String, dynamic> request = HashMap();
    request['token'] = token;
    if (email != null && email.isNotEmpty) {
      request['email'] = email;
    }
    request['payment_system'] = paymentSystem;
    request['data'] = data;
    return _call('api/checkout/ajax', request);
  }

  Future<http.Response> call3ds(String url, String body, String contentType) {
    if (_logging) {
      print('call3ds.Request. $url, $body');
    }

    final Map<String, String> headers = _headers();
    headers['Content-Type'] = contentType;

    return _httpClient.post(Uri.parse(url), headers: headers, body: body);
  }

  Future<dynamic> _call(String path, Map<String, dynamic> requestJson) async {
    final url = '$API_HOST/$path';
    final requestBody = jsonEncode({'request': requestJson});

    if (_logging) {
      print('Request. $url, $requestBody');
    }

    final Map<String, String> headers = _headers();
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';

    final response = await _httpClient.post(Uri.parse(url),
        headers: headers, body: requestBody);

    if (_logging) {
      print('Response. $url ${response.body}');
    }

    final responseRootJson = jsonDecode(response.body);
    final responseJson = responseRootJson['response'];
    if (responseJson['error_message'] != null) {
      throw CloudipspApiError(responseJson['error_code'],
          responseJson['request_id'], responseJson['error_message']);
    }
    return responseJson;
  }

  Map<String, String> _headers() {
    return {
      'User-Agent': 'Flutter',
      'SDK-OS': _platformSpecific.operatingSystem,
      'SDK-Version': '0.0.1'
    };
  }

  static _expMmFormat(int expMm) {
    if (expMm < 10) {
      return '0' + expMm.toString();
    }
    return expMm.toString();
  }
}
