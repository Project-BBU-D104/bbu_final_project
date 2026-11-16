import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_form_widget.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';
import 'warehouse_test_support.dart';

void main() {
  setUp(setUpWarehouseTests);
  tearDown(() => Get.reset());
  Future<WarehouseController> open(
    WidgetTester tester,
    FakeWarehouseService s, {
    bool edit = false,
    bool dark = false,
    Size size = const Size(390, 844),
    Locale locale = const Locale('en', 'US'),
    double textScale = 1,
    double keyboardInset = 0,
  }) async {
    final c = Get.put(WarehouseController(service: s));
    await pumpWarehouseHost(
      tester,
      size: size,
      dark: dark,
      locale: locale,
      textScale: textScale,
      keyboardInset: keyboardInset,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                edit ? c.editWarehouse(context, 1) : c.addWarehouse(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(AppFormActions));
    final actions = tester.widget<AppFormActions>(find.byType(AppFormActions));
    actions.onSave!();
    await tester.pumpAndSettle();
  }

  testWidgets('blank warehouse fields show inline errors', (tester) async {
    final s = FakeWarehouseService();
    await open(tester, s);
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Please enter warehouse name'), findsOneWidget);
    expect(find.text('Please enter location'), findsOneWidget);
  });
  testWidgets('trimmed warehouse payload preserves contract', (tester) async {
    final s = FakeWarehouseService();
    final c = await open(tester, s);
    c.warehouseNameController.text = ' Alpha ';
    c.warehouseLocationController.text = ' Phnom Penh ';
    c.warehouseReferenceNoController.text = '  ';
    c.warehouseNoteController.text = '  ';
    await save(tester);
    expect(s.lastCreatedData, {
      'name': 'Alpha',
      'reference_no': '',
      'location': 'Phnom Penh',
      'note': '',
    });
    expect(find.byType(WarehouseFormWidget), findsNothing);
  });
  testWidgets('saving prevents every dismissal path', (tester) async {
    final s = FakeWarehouseService()..createGate = Completer<dynamic>();
    final c = await open(tester, s);
    c.warehouseNameController.text = 'Alpha';
    c.warehouseLocationController.text = 'Phnom Penh';
    tester.widget<AppFormActions>(find.byType(AppFormActions)).onSave!();
    await tester.pump();
    expect(
      tester.widget<AppFormActions>(find.byType(AppFormActions)).onSave,
      isNull,
    );
    expect(
      tester.widget<AppFormActions>(find.byType(AppFormActions)).onCancel,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(WarehouseFormWidget), findsOneWidget);
    s.createGate!.complete(null);
    await tester.pumpAndSettle();
  });
  testWidgets('failed edit retains all fields', (tester) async {
    final s = FakeWarehouseService()..failWrite = true;
    final c = await open(tester, s, edit: true);
    c.warehouseNameController.text = 'Changed';
    c.warehouseReferenceNoController.text = 'R1';
    c.warehouseLocationController.text = 'Siem Reap';
    c.warehouseNoteController.text = 'Draft';
    await save(tester);
    expect(s.updateCalls, 1);
    expect(c.warehouseNameController.text, 'Changed');
    expect(c.warehouseReferenceNoController.text, 'R1');
    expect(c.warehouseLocationController.text, 'Siem Reap');
    expect(c.warehouseNoteController.text, 'Draft');
    expect(
      find.text('Unable to save warehouse. Please try again.'),
      findsOneWidget,
    );
  });
  for (final width in [390.0, 1024.0]) {
    testWidgets('Khmer large text keyboard form at $width', (tester) async {
      await open(
        tester,
        FakeWarehouseService(),
        size: Size(width, 900),
        locale: const Locale('km', 'KH'),
        textScale: 2,
        keyboardInset: 300,
      );
      await save(tester);
      await tester.ensureVisible(find.byType(AppFormActions));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  for (final width in [390.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final locale in [
        const Locale('en', 'US'),
        const Locale('km', 'KH'),
      ]) {
        testWidgets(
          'form saving/error $width dark=$dark ${locale.languageCode}',
          (tester) async {
            final s = FakeWarehouseService()
              ..createGate = Completer<dynamic>()
              ..failWrite = true;
            final c = await open(
              tester,
              s,
              size: Size(width, 900),
              dark: dark,
              locale: locale,
              textScale: 2,
              keyboardInset: 300,
            );
            c.warehouseNameController.text = 'Alpha';
            c.warehouseLocationController.text = 'Phnom Penh';
            tester
                .widget<AppFormActions>(find.byType(AppFormActions))
                .onSave!();
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(c.isSaving.value, true);
            s.createGate!.complete(null);
            await tester.pumpAndSettle();
            expect(find.byType(WarehouseFormWidget), findsOneWidget);
            expect(c.formError.value, isNotEmpty);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
