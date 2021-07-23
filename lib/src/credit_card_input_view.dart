import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import './credit_card.dart';
import './credit_card_cvv_field.dart';
import './credit_card_exp_mm_field.dart';
import './credit_card_exp_yy_field.dart';
import './credit_card_number_field.dart';
import './credit_card_input_layout.dart';

class CreditCardInputView extends StatefulWidget {
  final bool _helperNeeded;
  final InputDecoration _inputNumberDecoration;
  final InputDecoration _inputExpMmDecoration;
  final InputDecoration _inputExpYyDecoration;
  final InputDecoration _inputCvvDecoration;
  final InputDecoration _inputDecoration;

  CreditCardInputView(
      {Key key,
      bool helperNeeded = false,
      InputDecoration inputNumberDecoration,
      InputDecoration inputExpMmDecoration,
      InputDecoration inputExpYyDecoration,
      InputDecoration inputCvvDecoration,
      InputDecoration inputDecoration})
      : _helperNeeded = helperNeeded,
        _inputNumberDecoration = inputNumberDecoration,
        _inputExpMmDecoration = inputExpMmDecoration,
        _inputExpYyDecoration = inputExpYyDecoration,
        _inputCvvDecoration = inputCvvDecoration,
        _inputDecoration = inputDecoration,
        super(key: key);

  @override
  CreditCardInputViewState createState() {
    return CreditCardInputViewState(
        helperNeeded: _helperNeeded,
        inputNumberDecoration: _inputNumberDecoration,
        inputExpMmDecoration: _inputExpMmDecoration,
        inputExpYyDecoration: _inputExpYyDecoration,
        inputCvvDecoration: _inputCvvDecoration,
        inputDecoration: _inputDecoration);
  }
}

class CreditCardInputViewState extends State<CreditCardInputView>
    implements CreditCardInputState {
  static const _HELP_CARDS = [
    '4444555566661111',
    '4444111166665555',
    '4444555511116666',
    '4444111155556666'
  ];

  final bool _helperNeeded;
  final InputDecoration _inputNumberDecoration;
  final InputDecoration _inputExpMmDecoration;
  final InputDecoration _inputExpYyDecoration;
  final InputDecoration _inputCvvDecoration;
  final InputDecoration _inputDecoration;
  final GlobalKey _creditCardInputLayoutKey = GlobalKey();

  int _currentHelpCardIndex = 0;

  CreditCardInputViewState(
      {bool helperNeeded = false,
      InputDecoration inputNumberDecoration,
      InputDecoration inputExpMmDecoration,
      InputDecoration inputExpYyDecoration,
      InputDecoration inputCvvDecoration,
      InputDecoration inputDecoration})
      : _helperNeeded = helperNeeded,
        _inputNumberDecoration = inputNumberDecoration,
        _inputExpMmDecoration = inputExpMmDecoration,
        _inputExpYyDecoration = inputExpYyDecoration,
        _inputCvvDecoration = inputCvvDecoration,
        _inputDecoration = inputDecoration;

  @override
  CreditCard getCard() {
    final creditCardInputLayoutState =
        _creditCardInputLayoutKey.currentState as CreditCardInputLayoutState;
    if (creditCardInputLayoutState == null) {
      throw StateError("CreditCardInputView hasn't been rendered yet");
    }
    return creditCardInputLayoutState.getCard();
  }

  void _nextHelpCard() {
    final creditCardInputLayoutState =
        _creditCardInputLayoutKey.currentState as CreditCardInputLayoutState;

    _currentHelpCardIndex %= _HELP_CARDS.length;
    creditCardInputLayoutState.setHelpCard(
        _HELP_CARDS[_currentHelpCardIndex++], '12', '29', '111');
  }

  @override
  Widget build(BuildContext context) {
    Widget cardNumberLabel =
        Text('CardNumber:', textDirection: TextDirection.ltr);
    if (_helperNeeded) {
      cardNumberLabel = GestureDetector(
        onTap: _nextHelpCard,
        child: cardNumberLabel,
      );
    }

    return CreditCardInputLayout(
        key: _creditCardInputLayoutKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cardNumberLabel,
            CreditCardNumberField(
                decoration: _oneOf(_inputNumberDecoration, _inputDecoration)),
            SizedBox(
              height: 15.0,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exp. Year', textDirection: TextDirection.ltr),
                        CreditCardExpYyField(
                            decoration: _oneOf(
                                _inputExpYyDecoration, _inputDecoration)),
                      ],
                    )),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exp. Month', textDirection: TextDirection.ltr),
                        CreditCardExpMmField(
                            decoration: _oneOf(
                                _inputExpMmDecoration, _inputDecoration)),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Text('Cvv:', textDirection: TextDirection.ltr),
            CreditCardCvvField(
                decoration: _oneOf(_inputCvvDecoration, _inputDecoration))
          ],
        ));
  }

  static InputDecoration _oneOf(
      InputDecoration main, InputDecoration alternative) {
    if (main != null) {
      return main;
    }
    return alternative;
  }
}
