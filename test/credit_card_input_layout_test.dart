import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:cloudipsp_mobile/src/credit_card.dart';
import 'package:cloudipsp_mobile/src/credit_card_input_layout.dart';

import './utils.dart';

void main() {
  testWidgets('should render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CreditCardInputLayout(
                child: Column(children: [
      CreditCardNumberField(),
      CreditCardExpMmField(),
      CreditCardExpYyField(),
      CreditCardCvvField(),
    ])))));

    expect(findWidget<CreditCardNumberField>(), findsOneWidget);
    expect(findWidget<CreditCardExpMmField>(), findsOneWidget);
    expect(findWidget<CreditCardExpYyField>(), findsOneWidget);
    expect(findWidget<CreditCardCvvField>(), findsOneWidget);
  });

  testWidgets('should render correctly with nested ProxyWidget',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CreditCardInputLayout(
                child: Column(children: [
      Expanded(child: CreditCardNumberField()),
      CreditCardExpMmField(),
      CreditCardExpYyField(),
      CreditCardCvvField(),
    ])))));

    expect(findWidget<CreditCardNumberField>(), findsOneWidget);
    expect(findWidget<CreditCardExpMmField>(), findsOneWidget);
    expect(findWidget<CreditCardExpYyField>(), findsOneWidget);
    expect(findWidget<CreditCardCvvField>(), findsOneWidget);
  });

  testWidgets('should returns invalid card without entering',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CreditCardInputLayout(
                child: Column(children: [
      CreditCardNumberField(),
      CreditCardExpMmField(),
      CreditCardExpYyField(),
      CreditCardCvvField(),
    ])))));

    final cardInputState = tester.state<CreditCardInputLayoutState>(
        find.byType(CreditCardInputLayoutImpl));
    final card = cardInputState.getCard();

    expect(card.isValid(), false);
  });

  testWidgets('should returns valid card by setHelpCard',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CreditCardInputLayout(
                child: Column(children: [
      CreditCardNumberField(),
      CreditCardExpMmField(),
      CreditCardExpYyField(),
      CreditCardCvvField(),
    ])))));

    final cardInputState = tester.state<CreditCardInputLayoutState>(
        find.byType(CreditCardInputLayoutImpl));
    cardInputState.setHelpCard('4444555566661111', '11', '25', '919');
    final card = cardInputState.getCard() as PrivateCreditCard;

    expect(card.cardNumber, '4444555566661111');
    expect(card.mm, 11);
    expect(card.yy, 25);
    expect(card.cvv, '919');
  });

  testWidgets('should throw exception without CreditCardNumberField',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester
          .pumpWidget(CreditCardInputLayout(child: Column(children: [])));
      expect(tester.takeException(),
          stateError('CreditCardNumberField must exists in view tree'));
    });
  });

  testWidgets('should throw exception without CreditCardExpMmField',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(CreditCardInputLayout(
          child: Column(children: [CreditCardNumberField()])));
      expect(tester.takeException(),
          stateError('CreditCardExpMmField must exists in view tree'));
    });
  });

  testWidgets('should throw exception without CreditCardExpYyField',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(CreditCardInputLayout(
          child: Column(
              children: [CreditCardNumberField(), CreditCardExpMmField()])));
      expect(tester.takeException(),
          stateError('CreditCardExpYyField must exists in view tree'));
    });
  });

  testWidgets('should throw exception without CreditCardCvvField',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(CreditCardInputLayout(
          child: Column(children: [
        CreditCardNumberField(),
        CreditCardExpMmField(),
        CreditCardExpYyField()
      ])));
      expect(tester.takeException(),
          stateError('CreditCardCvvField must exists in view tree'));
    });
  });
}
