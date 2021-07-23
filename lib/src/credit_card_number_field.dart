import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CreditCardNumberField extends Widget {
  factory CreditCardNumberField({InputDecoration decoration}) = CreditCardNumberFieldImpl;
}

class CreditCardNumberFieldImpl extends StatelessWidget implements CreditCardNumberField {
  final textEditingController = TextEditingController(text: '');
  final InputDecoration _decoration;

  CreditCardNumberFieldImpl({InputDecoration decoration}): _decoration = decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      keyboardType: TextInputType.number,
      decoration: _decoration,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(19),
      ],
    );
  }
}