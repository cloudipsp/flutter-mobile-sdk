import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CreditCardExpMmField extends Widget {
  factory CreditCardExpMmField({InputDecoration? decoration}) =
      CreditCardExpMmFieldImpl;
}

class CreditCardExpMmFieldImpl extends StatelessWidget
    implements CreditCardExpMmField {
  final textEditingController = TextEditingController(text: '');
  final InputDecoration? _decoration;

  CreditCardExpMmFieldImpl({InputDecoration? decoration})
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
