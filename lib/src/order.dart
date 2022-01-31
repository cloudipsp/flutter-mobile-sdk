import 'dart:collection';
import 'package:email_validator/email_validator.dart';

enum Verification { amount, code }

enum Lang { ru, uk, en, lv, fr }

class Order {
  final int amount;
  final String currency;
  final String id;
  final String description;
  final String? email;

  String? _productId;
  String? paymentSystems;
  String? defaultPaymentSystem;
  int lifetime = -1;
  String? _merchantData;
  bool preauth = false;
  bool requiredRecToken = false;
  bool verification = false;
  Verification verificationType = Verification.amount;
  String? recToken;
  String? _version;
  Lang? lang;
  String? _serverCallbackUrl;
  String? reservationData;
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
    if (currency.length < 3) {
      throw ArgumentError.value(currency, 'currency');
    }
    if (id.length == 0 || id.length > 1024) {
      throw ArgumentError("id's length should be > 0 && <= 1024");
    }
    if (description.length == 0 || description.length > 1024) {
      throw ArgumentError("description's length should be > 0 && <= 1024");
    }
    if (email != null &&
        email!.isNotEmpty &&
        !EmailValidator.validate(email!)) {
      throw ArgumentError("email is not valid");
    }
  }

  String? get productId {
    return _productId;
  }

  set productId(String? value) {
    if (value != null && value.length > 1024) {
      throw ArgumentError('ProductId should be not more than 1024 symbols');
    }
    _productId = value;
  }

  String? get merchantData {
    return _merchantData;
  }

  set merchantData(String? value) {
    if (value != null && value.length > 2048) {
      throw new ArgumentError(
          "MerchantData should be not more than 2048 symbols");
    }
    _merchantData = value;
  }

  String? get version {
    return _version;
  }

  set version(String? value) {
    if (value != null && value.length > 10) {
      throw ArgumentError("version should be not more than 10 symbols");
    }
    _version = value;
  }

  String? get serverCallbackUrl {
    return _serverCallbackUrl;
  }

  set serverCallbackUrl(String? value) {
    if (value != null && value.length > 2048) {
      throw ArgumentError(
          "server callback url should be not more than 2048 symbols");
    }
    _serverCallbackUrl = value;
  }

  void addArgument(String name, String value) {
    arguments[name] = value;
  }
}
