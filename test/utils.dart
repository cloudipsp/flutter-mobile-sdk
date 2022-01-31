import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:cloudipsp_mobile/src/cloudipsp_error.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

Matcher thrownArgumentError(String message) {
  return throwsA(TypeMatcher<ArgumentError>()
      .having((e) => e.message, 'message', message));
}

Matcher thrownArgumentErrorValue(dynamic invalidValue, String name) {
  return throwsA(TypeMatcher<ArgumentError>()
      .having((e) => e.invalidValue, 'invalidValue', invalidValue)
      .having((e) => e.name, 'name', name));
}

Matcher thrownUnsupported(String message) {
  return throwsA(TypeMatcher<UnsupportedError>()
      .having((e) => e.message, 'message', message));
}

Matcher stateError(String message) {
  return TypeMatcher<StateError>().having((e) => e.message, 'message', message);
}

Matcher thrownStateError(String message) {
  return throwsA(
      TypeMatcher<StateError>().having((e) => e.message, 'message', message));
}

Matcher thrownCloudipspUserError(String code, String message) {
  return throwsA(TypeMatcher<CloudipspUserError>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.message, 'message', message));
}

Matcher thrownCloudipspApiError(int code, String requestId, String message) {
  return throwsA(TypeMatcher<CloudipspApiError>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.requestId, 'requestId', requestId)
      .having((e) => e.message, 'message', message));
}

Finder findWidget<T extends Widget>() {
  return find.byWidgetPredicate((Widget widget) => widget is T);
}
