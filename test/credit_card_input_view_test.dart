import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/credit_card.dart';
import 'package:cloudipsp_mobile/src/credit_card_input_view.dart';

import './utils.dart';

void main() {
  testWidgets('should render correctly CreditCardInputView',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: Scaffold(body: CreditCardInputView())));

    expect(find.text('CardNumber:'), findsOneWidget);
    expect(find.text('Exp. Year'), findsOneWidget);
    expect(find.text('Exp. Month'), findsOneWidget);
    expect(find.text('Cvv:'), findsOneWidget);

    expect(findWidget<CreditCardNumberField>(), findsOneWidget);
    expect(findWidget<CreditCardExpMmField>(), findsOneWidget);
    expect(findWidget<CreditCardExpYyField>(), findsOneWidget);
    expect(findWidget<CreditCardCvvField>(), findsOneWidget);
  });

  testWidgets('should returns valid card helper', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CreditCardInputView(helperNeeded: true))));

    final cardInputState = tester
        .state<CreditCardInputViewState>(find.byType(CreditCardInputView));

    await tester.tap(find.text('CardNumber:'));
    final card1 = cardInputState.getCard() as PrivateCreditCard;
    expect(card1.cardNumber, '4444555566661111');
    expect(card1.mm, 12);
    expect(card1.yy, 29);
    expect(card1.cvv, '111');

    await tester.tap(find.text('CardNumber:'));
    final card2 = cardInputState.getCard() as PrivateCreditCard;
    expect(card2.cardNumber, '4444111166665555');
    expect(card2.mm, 12);
    expect(card2.yy, 29);
    expect(card2.cvv, '111');
  });

  test(
      'should throw exception when CreditCardInputState did not rendered well, but card is going to take',
      () {
    final cardInputViewState = CreditCardInputViewState();
    expect(() => cardInputViewState.getCard(),
        thrownStateError("CreditCardInputView hasn't been rendered yet"));
  });
}
