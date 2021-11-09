import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/credit_card_cvv_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './utils.dart';

void main() {
  testWidgets('should cut cvv from 4 symbols to 3 on switching mode',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: CreditCardCvvField())));

    final finderCvv = findWidget<CreditCardCvvField>();
    expect(finderCvv, findsOneWidget);
    final cvvFieldImpl = tester.widget(finderCvv) as CreditCardCvvFieldImpl;
    cvvFieldImpl.setCvv4(true);
    cvvFieldImpl.textEditingController.text = '1234';
    cvvFieldImpl.setCvv4(false);
    expect(cvvFieldImpl.textEditingController.text, '123');
  });
}
