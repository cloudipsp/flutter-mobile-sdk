import 'dart:async';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

enum ExampleOrderMode {
  Order,
  Token,
}

enum ExampleCardInputMode {
  CardInputView,
  CardInputLayout,
}

class _ExampleState extends State<Example> {
  ExampleOrderMode _orderMode = ExampleOrderMode.Order;
  ExampleCardInputMode _cardInputMode = ExampleCardInputMode.CardInputView;

  CloudipspWebViewConfirmation? _cloudipspWebViewConfirmation;
  bool _supportsApplePay = false;
  bool _supportsGooglePay = false;
  final _tokenEditingController = TextEditingController(text: '');
  final _merchantIdEditingController = TextEditingController(text: '1396424');
  final _amountEditingController = TextEditingController(text: '1');
  final _emailEditingController =
      TextEditingController(text: 'example@test.com');
  final _descriptionEditingController =
      TextEditingController(text: 'test payment :)');
  String _selectedCurrency = 'UAH';

  final GlobalKey _cloudipspWebViewKey = GlobalKey();
  final GlobalKey _creditCardInputKey = GlobalKey();

  Cloudipsp? _cloudipsp;

  @override
  void initState() {
    super.initState();
    _checkAppleAndGooglePays();
  }

  Future<void> _checkAppleAndGooglePays() async {
    final cloudipsp = _getCloudipsp();
    final bool? supportsApplePay = await cloudipsp.supportsApplePay();
    final bool? supportsGooglePay = await cloudipsp.supportsGooglePay();

    if (!mounted) return;

    setState(() {
      _supportsApplePay = supportsApplePay!;
      _supportsGooglePay = supportsGooglePay!;
    });
  }

  void _cloudipspWebViewHolder(CloudipspWebViewConfirmation confirmation) {
    setState(() {
      _cloudipspWebViewConfirmation = confirmation;
    });
  }

  Cloudipsp _getCloudipsp() {
    int merchantId;
    try {
      merchantId = int.parse(_merchantIdEditingController.text);
    } catch (e) {
      throw ("Invalid MerchantID");
    }
    if (_cloudipsp == null || _cloudipsp!.merchantId != merchantId) {
      _cloudipsp = Cloudipsp(merchantId, _cloudipspWebViewHolder);
    }
    return _cloudipsp!;
  }

  void _payScope(Future<Receipt?> Function(Cloudipsp cloudipsp) handler) async {
    String? info;
    try {
      final cloudipsp = _getCloudipsp();
      final receipt = await handler(cloudipsp);
      if (receipt != null) {
        info = 'Paid ${receipt.status}, ID: ${receipt.paymentId}';
      }
    } on String catch (e) {
      info = e;
    } on CloudipspError catch (e) {
      info = 'CloudipspError: ${e.message}';
    } catch (e) {
      info = 'AnotherError: ${e.toString()}';
      return;
    }

    if (info != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(info), duration: Duration(milliseconds: 4000)),
      );
    }

    setState(() {
      _cloudipspWebViewConfirmation = null;
    });
  }

  Order _getOrder() {
    int amount;
    try {
      amount = int.parse(_amountEditingController.text);
    } catch (e) {
      throw ("Invalid amount");
    }
    final email = _emailEditingController.text;
    if (email.isEmpty || !EmailValidator.validate(email)) {
      throw ("Invalid email");
    }
    final description = _descriptionEditingController.text;
    if (description.isEmpty) {
      throw ("Invalid description");
    }
    return Order(
      amount,
      _selectedCurrency,
      'Flutter_${DateTime.now().millisecondsSinceEpoch}',
      description,
      email,
    );
  }

  String _getToken() {
    final token = _tokenEditingController.text;
    if (token.isEmpty) {
      throw ("Invalid token");
    }
    return token;
  }

  CreditCard _getCreditCard() {
    final creditCard =
        (_creditCardInputKey.currentState as CreditCardInputState).getCard();
    if (!creditCard.isValidCardNumber()) {
      throw ("Invalid card number");
    } else if (!creditCard.isValidExpireMonth()) {
      throw ("Invalid expire month");
    } else if (!creditCard.isValidExpireYear()) {
      throw ("Invalid expire year");
    } else if (!creditCard.isValidExpireDate()) {
      throw ("Invalid expire date");
    } else if (!creditCard.isValidCvv()) {
      throw ("Invalid cvv");
    } else if (!creditCard.isValid()) {
      throw ("Invalid card");
    }
    return creditCard;
  }

  void _onPayByCardPressed() async {
    _payScope((cloudipsp) {
      final creditCard = _getCreditCard();
      if (_orderMode == ExampleOrderMode.Order) {
        return cloudipsp.pay(creditCard, _getOrder());
      } else if (_orderMode == ExampleOrderMode.Token) {
        return cloudipsp.payToken(creditCard, _getToken());
      } else {
        throw StateError('Unsupported mode $_orderMode');
      }
    });
  }

  void _onGetTokenPressed() async {
    _payScope((cloudipsp) async {
      final String? token = await cloudipsp.getToken(_getOrder());
      setState(() {
        _tokenEditingController.text = token!;
      });
      return null;
    });
  }

  void _onApplePayPressed() async {
    _payScope((cloudipsp) async {
      if (_orderMode == ExampleOrderMode.Order) {
        return _cloudipsp!.applePay(_getOrder());
      } else if (_orderMode == ExampleOrderMode.Token) {
        return _cloudipsp!.applePayToken(_getToken());
      } else {
        throw StateError('Unsupported order mode $_orderMode');
      }
    });
  }

  Future<void> _onGooglePayPressed() async {
    _payScope((cloudipsp) async {
      if (_orderMode == ExampleOrderMode.Order) {
        return _cloudipsp!.googlePay(_getOrder());
      } else if (_orderMode == ExampleOrderMode.Token) {
        return _cloudipsp!.googlePayToken(_getToken());
      } else {
        throw StateError('Unsupported order mode $_orderMode');
      }
    });
  }

  Widget _cardInputLayout() {
    return CreditCardInputLayout(
        key: _creditCardInputKey,
        child: Column(
          children: [
            Text('----My Custom CreditCardNumber----'),
            CreditCardNumberField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text('ExpMM:'),
                      CreditCardExpMmField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text('ExpYY:'),
                      CreditCardExpYyField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text('CVV:'),
                      CreditCardCvvField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ))
            ])
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> controls = [
      Expanded(
        child: TextButton(
          child: Text('Pay by Card'),
          onPressed: _onPayByCardPressed,
        ),
      ),
    ];
    if (_orderMode == ExampleOrderMode.Order) {
      controls.add(Expanded(
        child: TextButton(
          child: Text('Get Token'),
          onPressed: _onGetTokenPressed,
        ),
      ));
    }
    if (_supportsApplePay) {
      controls.add(Expanded(
        child: TextButton(
          child: Text('ApplePay'),
          onPressed: _onApplePayPressed,
        ),
      ));
    } else if (_supportsGooglePay) {
      controls.add(Expanded(
        child: TextButton(
          child: Text('GooglePay'),
          onPressed: _onGooglePayPressed,
        ),
      ));
    }

    final List<Widget> mainUi = [
      Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order mode:'),
                DropdownButton(
                  value: _orderMode,
                  onChanged: (ExampleOrderMode? newOrderMode) {
                    if (newOrderMode == ExampleOrderMode.Order &&
                        _orderMode != ExampleOrderMode.Order) {
                      _tokenEditingController.text = '';
                    }
                    setState(() {
                      _orderMode = newOrderMode!;
                    });
                  },
                  items: ExampleOrderMode.values
                      .map<DropdownMenuItem<ExampleOrderMode>>(
                          (ExampleOrderMode value) {
                    return DropdownMenuItem<ExampleOrderMode>(
                      value: value,
                      child: Text(
                        describeEnum(value),
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            flex: 2,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Card Input Type:'),
              DropdownButton(
                value: _cardInputMode,
                onChanged: (ExampleCardInputMode? newCardInputMode) {
                  setState(() {
                    _cardInputMode = newCardInputMode!;
                  });
                },
                items: ExampleCardInputMode.values
                    .map<DropdownMenuItem<ExampleCardInputMode>>(
                        (ExampleCardInputMode value) {
                  return DropdownMenuItem<ExampleCardInputMode>(
                    value: value,
                    child: Text(
                      describeEnum(value),
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }).toList(),
              )
            ]),
          ),
          SizedBox(
            height: 15.0,
          ),
        ],
      )
    ];
    if (_orderMode == ExampleOrderMode.Order) {
      mainUi.addAll([
        Text('MerchantID:'),
        TextField(
          controller: _merchantIdEditingController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your MerchantID',
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              flex: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount in cents, 123 means 1.23 $_selectedCurrency'),
                    TextField(
                      controller: _amountEditingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter order amount',
                      ),
                    ),
                  ])),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            flex: 1,
            child: DropdownButton(
              value: _selectedCurrency,
              onChanged: (String? newCurrency) {
                setState(() {
                  _selectedCurrency = newCurrency!;
                });
              },
              items: <String>['UAH', 'USD', 'EUR', 'GBP', 'RUB', 'KZT']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
          )
        ]),
        SizedBox(
          height: 15.0,
        ),
        Text('Email:'),
        TextFormField(
          controller: _emailEditingController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter email for receipt',
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Text('Description:'),
        TextFormField(
          controller: _descriptionEditingController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Just some info about your purchase',
          ),
        )
      ]);
    } else if (_orderMode == ExampleOrderMode.Token) {
      mainUi.addAll([
        Text('Token:'),
        TextField(
          controller: _tokenEditingController,
          maxLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter token',
          ),
        )
      ]);
    } else {
      throw StateError('Unsupported order mode: $_orderMode');
    }

    mainUi.add(SizedBox(height: 15.0));

    if (_cardInputMode == ExampleCardInputMode.CardInputView) {
      mainUi.add(CreditCardInputView(
          key: _creditCardInputKey,
          helperNeeded: kDebugMode,
          inputDecoration: InputDecoration(border: OutlineInputBorder())));
    } else if (_cardInputMode == ExampleCardInputMode.CardInputLayout) {
      mainUi.add(_cardInputLayout());
    } else {
      throw StateError('Unsupported card input mode: $_cardInputMode');
    }

    if (_tokenEditingController.text.isNotEmpty &&
        _orderMode == ExampleOrderMode.Order) {
      mainUi.addAll([
        SizedBox(
          height: 15.0,
        ),
        Text('Generated token:'),
        TextFormField(
          controller: _tokenEditingController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )
      ]);
    }

    mainUi.add(Row(children: controls));

    return Stack(children: [
      SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: mainUi,
        ),
      )),
      if (_cloudipspWebViewConfirmation != null)
        Positioned.fill(
            child: CloudipspWebView(
          key: _cloudipspWebViewKey,
          confirmation: _cloudipspWebViewConfirmation!,
        ))
    ]);
  }
}
