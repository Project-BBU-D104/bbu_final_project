import 'dart:io';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/screen/customer/customer_screen.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:get/get.dart';
import 'customer_test_support.dart';

class _FakeUploadController extends ImageUploadController {
  int clearCalls = 0;

  @override
  void clearImage() {
    clearCalls++;
    super.clearImage();
  }

  @override
  Future<void> pickImage() async {}

  @override
  Future<String?> uploadImage({
    required String bucket,
    String folder = '',
  }) async {
    return 'https://cdn.example/customers/new.jpg';
  }
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  Future<CustomerController> seed(
    WidgetTester tester,
    FakeCustomerService service,
  ) async {
    final c = CustomerController(service: service);
    await c.getCustomers();
    Get.put<CustomerController>(c);
    await pumpCustomerHost(tester, home: CustomerScreen());
    return c;
  }

  void fill(CustomerController c) {
    c.customerNameController.text = ' Dara ';
    c.customerPhoneNumberController.text = ' 012 ';
    c.customerAddressController.text = ' PP ';
    c.isActive.value = true;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('blank name never writes', (tester) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Customer name is required'), findsOneWidget);
    c.customerNameController.text = '   ';
    await c.onSaveCustomer(tester.element(find.byType(AddCustomerWidget)));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
  });

  testWidgets('trimmed payload keeps the customer contract', (tester) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(s.lastCreatedData, {
      'photo': '',
      'name': 'Dara',
      'phone': '012',
      'address': 'PP',
      'is_active': true,
    });
    expect(s.createCalls, 1);
    expect(find.byType(AddCustomerWidget), findsNothing);
  });

  testWidgets('photo url reaches the payload', (tester) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    c.customerPhotoController.text = ' https://x/y.jpg ';
    // Bounded frames only: a displayed network URL's placeholder animates
    // forever under test HTTP overrides (product_form_test precedent).
    // Advance past the success toast's 3s dismiss timer so none is pending.
    await c.onSaveCustomer(tester.element(find.byType(AddCustomerWidget)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(s.lastCreatedData!['photo'], 'https://x/y.jpg');
  });

  testWidgets('write failure preserves the draft and shows an error', (
    tester,
  ) async {
    final s = FakeCustomerService()..failWrite = true;
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(c.customerNameController.text, ' Dara ');
    expect(find.byType(AddCustomerWidget), findsOneWidget);
    expect(
      find.text('Unable to save customer. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = DelayedCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final context = tester.element(find.byType(AddCustomerWidget));
    c.onSaveCustomer(context);
    c.onSaveCustomer(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddCustomerWidget), findsOneWidget);
    s.create.complete(customerJson(3, 'Dara'));
    await tester.pumpAndSettle();
    expect(find.byType(AddCustomerWidget), findsNothing);
  });

  testWidgets('edit prefills status and saves a real bool', (tester) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    await c.editCustomer(tester.element(find.byType(CustomerScreen)), 1);
    await tester.pumpAndSettle();
    expect(find.byType(EditCustomerWidget), findsOneWidget);
    expect(c.isActive.value, isTrue);
    c.isActive.value = false;
    c.customerNameController.text = 'Updated';
    await save(tester);
    expect(s.lastUpdatedData!['is_active'], isFalse);
    expect(c.customerList.first['name'], 'Updated');
    expect(find.byType(EditCustomerWidget), findsNothing);
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('refresh failure after a committed save keeps the new row', (
    tester,
  ) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    s.failGet = true;
    await save(tester);
    expect(s.createCalls, 1);
    expect(
      c.customerList.any((e) => e['name'] == 'Dara' && e['id'] == 3),
      isTrue,
    );
    expect(find.byType(AddCustomerWidget), findsNothing);
    expect(c.loadError.value, isNotEmpty);
  });

  testWidgets('late edit fetch never opens on another page', (tester) async {
    final s = DelayedCustomerService();
    final c = await seed(tester, s);
    final ctx = tester.element(find.byType(CustomerScreen));
    c.editCustomer(ctx, 1);
    c.editCustomer(ctx, 1);
    Get.to(() => const Scaffold(body: Text('Other')));
    await tester.pumpAndSettle();
    s.edit.complete(customerJson(1, 'Late'));
    await tester.pumpAndSettle();
    expect(s.getByIdCalls, 1);
    expect(find.byType(EditCustomerWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete cancel, failure, and success keep the list route', (
    tester,
  ) async {
    final s = FakeCustomerService();
    final c = await seed(tester, s);
    Future<void> openDelete() async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
    }

    await openDelete();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 0);
    s.failWrite = true;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(c.customerList.length, 2);
    s.failWrite = false;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(c.customerList.map((e) => e['id']), [2]);
  });

  testWidgets('failed update preserves the draft and blank names never write', (
    tester,
  ) async {
    final s = FakeCustomerService()..failWrite = true;
    final c = await seed(tester, s);
    await c.editCustomer(tester.element(find.byType(CustomerScreen)), 1);
    await tester.pumpAndSettle();
    c.customerNameController.text = 'Changed';
    await save(tester);
    expect(c.customerNameController.text, 'Changed');
    expect(find.byType(EditCustomerWidget), findsOneWidget);
    c.customerNameController.text = ' ';
    await c.onUpdateCustomer(
      1,
      tester.element(find.byType(EditCustomerWidget)),
    );
    expect(s.updateCalls, 1);
  });

  testWidgets('form survives keyboard, Khmer, and large text', (tester) async {
    final c = await seed(tester, FakeCustomerService());
    await pumpCustomerHost(
      tester,
      home: CustomerScreen(),
      locale: const Locale('km', 'KH'),
      dark: true,
      textScale: 2,
    );
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'.tr));
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller disposal during a write never pops another page', (
    tester,
  ) async {
    final s = DelayedCustomerService();
    final c = await seed(tester, s);
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final pending = c.onSaveCustomer(
      tester.element(find.byType(AddCustomerWidget)),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    Get.delete<CustomerController>(force: true);
    s.create.complete(customerJson(3, 'Dara'));
    await pending;
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop form opens as a dialog', (tester) async {
    final c = await seed(tester, FakeCustomerService());
    await pumpCustomerHost(
      tester,
      home: CustomerScreen(),
      size: const Size(1440, 900),
    );
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AddCustomerWidget), findsOneWidget);
  });

  testWidgets('opening add clears the previous photo preview', (tester) async {
    final upload = _FakeUploadController();
    Get.put<ImageUploadController>(upload);
    final c = await seed(tester, FakeCustomerService());
    upload.file.value = File('previous.png');
    c.customerPhotoController.text = 'https://x/old.jpg';
    c.addCustomer(tester.element(find.byType(CustomerScreen)));
    await tester.pumpAndSettle();
    expect(upload.file.value, isNull);
    expect(c.customerPhotoController.text, '');
    expect(upload.clearCalls, 1);
  });
}
