import 'package:flutter_test/flutter_test.dart';

import 'package:cloudipsp_mobile/cloudipsp_mobile.dart';

void main() {
  group('Receipt', () {
    late dynamic orderData;
    setUp(() {
      orderData = {
        'masked_card': '4444*6666',
        'card_bin': 4444,
        'amount': '100500',
        'payment_id': 500100,
        'currency': 'UAH',
        'order_status': 'approved',
        'tran_type': 'purchase',
        'sender_cell_phone': '',
        'sender_account': '',
        'card_type': 'MAESTRO',
        'rrn': '',
        'approval_code': '',
        'response_code': -1,
        'product_id': 'productID',
        'rectoken': null,
        'rectoken_lifetime': null,
        'reversal_amount': '0',
        'settlement_amount': '0',
        'settlement_currency': null,
        'settlement_date': null,
        'eci': '1',
        'fee': '2',
        'actual_amount': '3',
        'actual_currency': 'UAH',
        'payment_system': 'test',
        'verification_status': null,
        'signature': 'Sign'
      };
    });

    test('basic parsing', () {
      final receipt = Receipt.fromJson(orderData, 'mocked_response_url')!;
      expect(receipt.maskedCard, '4444*6666');
      expect(receipt.cardBin, 4444);
      expect(receipt.amount, 100500);
      expect(receipt.paymentId, 500100);
      expect(receipt.currency, 'UAH');
      expect(receipt.status, Status.approved);
      expect(receipt.transactionType, TransactionType.purchase);
      expect(receipt.senderCellPhone, '');
      expect(receipt.cardType, CardType.MAESTRO);
      expect(receipt.rrn, '');
      expect(receipt.approvalCode, '');
      expect(receipt.responseCode, -1);
      expect(receipt.productId, 'productID');
      expect(receipt.recToken, null);
      expect(receipt.recTokenLifeTime, null);
      expect(receipt.reversalAmount, 0);
      expect(receipt.settlementAmount, 0);
      expect(receipt.settlementCurrency, null);
      expect(receipt.settlementDate, null);
      expect(receipt.eci, 1);
      expect(receipt.fee, 2);
      expect(receipt.actualAmount, 3);
      expect(receipt.actualCurrency, 'UAH');
      expect(receipt.paymentSystem, 'test');
      expect(receipt.verificationStatus, null);
      expect(receipt.signature, 'Sign');
      expect(receipt.responseUrl, 'mocked_response_url');
    });

    test('with date parsing', () {
      orderData['rectoken_lifetime'] = '05.01.2021 01:31:04';
      final receipt = Receipt.fromJson(orderData, 'mocked_response_url')!;
      expect(receipt.recTokenLifeTime, DateTime(2021, 1, 5, 1, 31, 4));
    });

    test('with verification status', () {
      orderData['verification_status'] = 'verified';
      final receipt = Receipt.fromJson(orderData, 'mocked_response_url')!;
      expect(receipt.verificationStatus, VerificationStatus.verified);
    });

    test('with string on ints position', () {
      orderData['card_bin'] = '4444';
      final receipt = Receipt.fromJson(orderData, 'mocked_response_url')!;
      expect(receipt.cardBin, 4444);
    });
  });
}
