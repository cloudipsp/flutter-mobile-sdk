import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CreditCardExpYyField extends Widget {
  factory CreditCardExpYyField({InputDecoration? decoration}) =
      CreditCardExpYyFieldImpl;
}

class CreditCardExpYyFieldImpl extends StatelessWidget
    implements CreditCardExpYyField {
  final textEditingController = TextEditingController(text: '');
  final InputDecoration? _decoration;

  CreditCardExpYyFieldImpl({InputDecoration? decoration})
      : _decoration = decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      keyboardType: TextInputType.number,
      decoration: _decoration,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(2),
      ],
    );
  }
}
