import 'dart:async';

import 'package:http/http.dart' as http;

import './receipt.dart';

abstract class CloudipspWebViewConfirmation {}

typedef void SuccessCallback();

class PrivateCloudipspWebViewConfirmation extends CloudipspWebViewConfirmation {
  final String apiHost;
  final String baseUrl;
  final String callbackUrl;
  final http.Response response;
  final Completer<Receipt> completer;

  PrivateCloudipspWebViewConfirmation(this.apiHost, this.baseUrl,
      this.callbackUrl, this.response, this.completer);
}
