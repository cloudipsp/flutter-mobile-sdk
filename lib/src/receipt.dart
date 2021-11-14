import 'package:cloudipsp_mobile/src/credit_card.dart';
import 'package:flutter/foundation.dart';

enum Status { created, processing, declined, approved, expired, reversed }

enum TransactionType { purchase, reverse, verification }

enum VerificationStatus { verified, incorrect, failed, created }

class Receipt {
  final String? maskedCard;
  final int? cardBin;
  final int amount;
  final int? paymentId;
  final String? currency;
  final Status status;
  final TransactionType? transactionType;
  final String? senderCellPhone;
  final String? senderAccount;
  final CardType? cardType;
  final String? rrn;
  final String? approvalCode;
  final int? responseCode;
  final String? productId;
  final String orderId;
  final DateTime? orderTime;
  final String? recToken;
  final DateTime? recTokenLifeTime;
  final int? reversalAmount;
  final int? settlementAmount;
  final String? settlementCurrency;
  final DateTime? settlementDate;
  final int? eci;
  final int? fee;
  final int? actualAmount;
  final String? actualCurrency;
  final String? paymentSystem;
  final VerificationStatus? verificationStatus;
  final String? signature;
  final String? responseUrl;

  Receipt(
      this.maskedCard,
      this.cardBin,
      this.amount,
      this.paymentId,
      this.currency,
      this.status,
      this.transactionType,
      this.senderCellPhone,
      this.senderAccount,
      this.cardType,
      this.rrn,
      this.approvalCode,
      this.responseCode,
      this.productId,
      this.orderId,
      this.orderTime,
      this.recToken,
      this.recTokenLifeTime,
      this.reversalAmount,
      this.settlementAmount,
      this.settlementCurrency,
      this.settlementDate,
      this.eci,
      this.fee,
      this.actualAmount,
      this.actualCurrency,
      this.paymentSystem,
      this.verificationStatus,
      this.signature,
      this.responseUrl);

  static Receipt? fromJson(dynamic orderData, String? responseUrl) {
    try {
      return Receipt(
          orderData['masked_card'],
          _safeIntParse(orderData['card_bin']),
          int.parse(orderData['amount']),
          orderData['payment_id'],
          orderData['currency'],
          _statusFromString(orderData['order_status']),
          _transactionTypeFromString(orderData['tran_type']),
          orderData['sender_cell_phone'],
          orderData['sender_account'],
          _cardTypeFromString(orderData['card_type']),
          orderData['rrn'],
          orderData['approval_code'],
          _safeIntParse(orderData['response_code']),
          orderData['product_id'],
          orderData['order_id'],
          parseDate(orderData['order_time']),
          orderData['rectoken'],
          parseDate(orderData['rectoken_lifetime']),
          int.tryParse(orderData['reversal_amount']),
          int.tryParse(orderData['settlement_amount']),
          orderData['settlement_currency'],
          parseDate(orderData['settlement_date']),
          int.tryParse(orderData['eci']),
          int.tryParse(orderData['fee']),
          int.tryParse(orderData['actual_amount']),
          orderData['actual_currency'],
          orderData['payment_system'],
          _verificationStatusFromString(orderData['verification_status']),
          orderData['signature'],
          responseUrl);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDate(String? value) {
    //expected 05.01.2021 01:31:04
    //why should we use own parser instead of import external library ?
    //because we are library and we:
    //1. should be as tiny as possible
    //2. our clients/developers may use different libraries.
    try {
      if (value == null || value.length == 0) {
        return null;
      }
      final dateAndTime = value.split(' ');
      if (dateAndTime.length != 2) {
        return null;
      }
      final daysMonthsAndYears = dateAndTime[0].split('.');
      if (daysMonthsAndYears.length != 3) {
        return null;
      }
      final hoursMinutesSeconds = dateAndTime[1].split(':');

      return DateTime(
          int.parse(daysMonthsAndYears[2]),
          int.parse(daysMonthsAndYears[1]),
          int.parse(daysMonthsAndYears[0]),
          int.parse(hoursMinutesSeconds[0]),
          int.parse(hoursMinutesSeconds[1]),
          int.parse(hoursMinutesSeconds[2]));
    } catch (e) {
      return null;
    }
  }

  static Status _statusFromString(String? value) {
    return Status.values
        .firstWhere((element) => describeEnum(element) == value);
  }

  static CardType? _cardTypeFromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return CardType.values
        .firstWhere((element) => describeEnum(element) == value);
  }

  static TransactionType? _transactionTypeFromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return TransactionType.values
        .firstWhere((element) => describeEnum(element) == value);
  }

  static VerificationStatus? _verificationStatusFromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return VerificationStatus.values
        .firstWhere((element) => describeEnum(element) == value);
  }

  static int? _safeIntParse(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value);
  }
}
