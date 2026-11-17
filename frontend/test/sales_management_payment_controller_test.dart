import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/payment_controller.dart';

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  test('payment search covers nested fields independently', () {
    final ctr = PaymentController();
    ctr.paymentList.value = [
      {
        'sale': {
          'invoice_no': 'INV-42',
          'customer': {'name': 'Buyer'},
        },
        'amount': '12.50',
        'reference_no': 'REF',
      },
    ];
    ctr.searchCtr.keyword.value = 'buyer';
    expect(ctr.filteredPaymentList.length, 1);
    ctr.searchCtr.keyword.value = 'absent';
    expect(ctr.filteredPaymentList, isEmpty);
    ctr.onClose();
  });
}
