import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class CreditCardCvvField extends Widget {
  factory CreditCardCvvField(
      {InputDecoration decoration}) = CreditCardCvvFieldImpl;
}

class CreditCardCvvFieldImpl extends StatelessWidget
    implements CreditCardCvvField {
  final textEditingController = TextEditingController(text: '');
  final InputDecoration _decoration;
  final GlobalKey<CreditCardCvvFieldInternalState> _key = GlobalKey<
      CreditCardCvvFieldInternalState>();

  CreditCardCvvFieldImpl({InputDecoration decoration})
      : _decoration = decoration;

  setCvv4(bool enabled) {
    _key.currentState.setCvv4(enabled);
  }

  @override
  Widget build(BuildContext context) {
    return CreditCardCvvFieldInternal(_key, textEditingController, _decoration);
  }
}

class CreditCardCvvFieldInternal extends StatefulWidget {
  final TextEditingController _textEditingController;
  final InputDecoration _decoration;

  CreditCardCvvFieldInternal(Key key, this._textEditingController,
      this._decoration) : super(key: key);

  @override
  CreditCardCvvFieldInternalState createState() {
    return CreditCardCvvFieldInternalState(
        this._textEditingController, this._decoration);
  }
}

class CreditCardCvvFieldInternalState
    extends State<CreditCardCvvFieldInternal> {
  final TextEditingController _textEditingController;
  final InputDecoration _decoration;
  int _maxLength = 3;

  CreditCardCvvFieldInternalState(this._textEditingController,
      this._decoration);

  setCvv4(bool enabled) {
    setState(() {
      if (enabled) {
        _maxLength = 4;
      } else {
        _maxLength = 3;
        if (_textEditingController.text.length == 4) {
          _textEditingController.text = _textEditingController.text.substring(0, 3);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      keyboardType: TextInputType.number,
      decoration: _decoration,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(_maxLength),
      ],
    );
  }
}