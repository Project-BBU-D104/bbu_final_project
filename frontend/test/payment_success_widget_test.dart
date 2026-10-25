import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';

void main() {
  testWidgets('does not run animations after the widget is disposed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PaymentSuccessWidget()));

    // Let the badge and check animations finish, then stop during the
    // sequence's 100ms delay before it starts the content animation.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 50));

    // Simulate leaving the success screen before the sequence finishes.
    await tester.pumpWidget(const SizedBox());

    // Give the pending delay a chance to resume and call forward().
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });
}
