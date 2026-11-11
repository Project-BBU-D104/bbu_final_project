import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/widget/confirm_dailog_widget.dart';

void main() {
  Future<void> show(
    WidgetTester tester, {
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => ConfirmDialogWidget(
                    title: 'Confirm',
                    message: 'Do you want to delete this category?',
                    cancelText: 'Cancel',
                    confirmText: 'Ok',
                    onCancel: () {
                      Navigator.of(dialogContext).pop();
                      onCancel?.call();
                    },
                    onConfirm: () {
                      Navigator.of(dialogContext).pop();
                      onConfirm?.call();
                    },
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  void setView(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('confirm dialog has a comfortable width on desktop', (
    tester,
  ) async {
    setView(tester, const Size(1440, 900));
    await show(tester);
    expect(
      tester.getSize(find.byKey(const Key('confirm-dialog-surface'))).width,
      440,
    );
  });

  testWidgets('confirm dialog fits a phone width', (tester) async {
    setView(tester, const Size(390, 844));
    await show(tester);
    final width = tester
        .getSize(find.byKey(const Key('confirm-dialog-surface')))
        .width;
    expect(width, lessThanOrEqualTo(342));
    expect(width, greaterThanOrEqualTo(300));
  });

  testWidgets('destructive action is emphasized and targets are tappable', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await show(tester);
    final theme = Theme.of(tester.element(find.byType(Dialog)));
    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Ok'),
    );
    expect(confirm.style?.backgroundColor?.resolve({}), theme.colorScheme.error);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('cancel and confirm invoke their callbacks', (tester) async {
    var cancelled = 0, confirmed = 0;
    await show(
      tester,
      onCancel: () => cancelled++,
      onConfirm: () => confirmed++,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cancelled, 1);

    await show(
      tester,
      onCancel: () => cancelled++,
      onConfirm: () => confirmed++,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(confirmed, 1);
  });
}