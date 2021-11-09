import 'dart:collection';

import 'package:email_validator/email_validator.dart';

enum Verification { amount, code }

enum Lang { ru, uk, en, lv, fr }

class Order {
  final int amount;
  final String? currency;
  final String? id;
  final String? description;
  final String? email;

  String? _productId;
  String? _paymentSystems;
  String? _defaultPaymentSystem;
  int lifetime = -1;
  String? _merchantData;
  bool preauth = false;
  bool requiredRecToken = false;
  bool verification = false;
  Verification _verificationType = Verification.amount;
  String? _recToken;
  String? _version;
  Lang? _lang;
  String? _serverCallbackUrl;
  String? _reservationData;
  String? _paymentSystem;
  bool delayed = false;

  final Map<String, String> arguments = HashMap();

  Order(
    this.amount,
    this.currency,
    this.id,
    this.description,
    this.email,
  ) {
    if (amount < 0) {
      throw ArgumentError('Amount should be more than 0');
    }
    if (currency == null) {
      throw ArgumentError.notNull('currency');
    }
    if (currency!.length < 3) {
      throw ArgumentError.value(currency, 'currency');
    }
    if (id == null) {
      throw ArgumentError.notNull('id');
    }
    if (id!.length == 0 || id!.length > 1024) {
      throw ArgumentError("id's length should be > 0 && <= 1024");
    }
    if (description == null) {
      throw ArgumentError.notNull("description");
    }
    if (description!.length == 0 || description!.length > 1024) {
      throw ArgumentError("description's length should be > 0 && <= 1024");
    }
    if ((email != null && email!.isNotEmpty) &&
        !EmailValidator.validate(email!)) {
      throw ArgumentError("email is not valid");
    }
  }

  String? get productId {
    return _productId;
  }

  set productId(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("ProductId");
    }
    if (value.length > 1024) {
      throw ArgumentError('ProductId should be not more than 1024 symbols');
    }
    _productId = value;
  }

  String? get paymentSystems {
    return _paymentSystems;
  }

  set paymentSystems(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("paymentSystems");
    }
    _paymentSystems = value;
  }

  String? get defaultPaymentSystem {
    return _defaultPaymentSystem;
  }

  set defaultPaymentSystem(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("defaultPaymentSystem");
    }
    _defaultPaymentSystem = value;
  }

  String? get merchantData {
    return _merchantData;
  }

  set merchantData(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("merchantData");
    }
    if (value.length > 2048) {
      throw new ArgumentError(
          "MerchantData should be not more than 2048 symbols");
    }
    _merchantData = value;
  }

  Verification get verificationType {
    return _verificationType;
  }

  set verificationType(Verification? value) {
    if (value == null) {
      throw ArgumentError.notNull("verificationType");
    }
    _verificationType = value;
  }

  String? get recToken {
    return _recToken;
  }

  set recToken(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("recToken");
    }
    _recToken = value;
  }

  String? get version {
    return _version;
  }

  set version(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("version");
    }
    if (value.length > 10) {
      throw ArgumentError("version should be not more than 10 symbols");
    }
    _version = value;
  }

  Lang? get lang {
    return _lang;
  }

  set lang(Lang? value) {
    if (value == null) {
      throw ArgumentError.notNull("lang");
    }
    _lang = value;
  }

  String? get serverCallbackUrl {
    return _serverCallbackUrl;
  }

  set serverCallbackUrl(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("serverCallbackUrl");
    }
    if (value.length > 2048) {
      throw ArgumentError(
          "server callback url should be not more than 2048 symbols");
    }
    _serverCallbackUrl = value;
  }

  String? get reservationData {
    return _reservationData;
  }

  set reservationData(String? value) {
    if (value == null) {
      throw ArgumentError.notNull("reservationData");
    }
    _reservationData = value;
  }

  void addArgument(String name, String value) {
    arguments[name] = value;
  }
}
