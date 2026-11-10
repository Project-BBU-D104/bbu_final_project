import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/localization/km_kh.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/product/widget/product_form_widget.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'product_redesign_test.dart' show pumpProductScreen;
import 'product_test_support.dart';
import 'profile_widget_test.dart' show FakeStorageService;

class _TestStorage extends FakeStorageService {
  @override
  bool hasRole(String role) => false;
}

class _CountingSaleController extends SaleController {
  int categoryRefreshes = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> loadProductCategories() async {
    categoryRefreshes++;
  }
}

/// Completer-gated writes; can fail the next write on demand.
class _GatedProductService extends FakeProductService {
  _GatedProductService(super.items);

  Completer<dynamic>? gate;
  bool failNextCreate = false;
  bool failNextUpdate = false;
  bool failFetch = false;
  int fetchCalls = 0;

  @override
  Future<dynamic> createProduct(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (failNextCreate) {
      failNextCreate = false;
      throw Exception('server error');
    }
    final g = gate;
    if (g != null) return g.future;
    return data;
  }

  @override
  Future<dynamic> updateProduct(int id, Map<String, dynamic> data) async {
    updateCalls++;
    lastUpdatedData = data;
    if (failNextUpdate) {
      failNextUpdate = false;
      throw Exception('server error');
    }
    final g = gate;
    if (g != null) return g.future;
    return {'id': id, ...data};
  }

  @override
  Future<dynamic> getProductById(int id) async {
    fetchCalls++;
    if (failFetch) throw Exception('fetch failed');
    return super.getProductById(id);
  }
}

/// Upload controller that records interactions without touching plugins.
class _FakeUploadController extends ImageUploadController {
  int clearCalls = 0;
  String? lastBucket;
  String? lastFolder;

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
    lastBucket = bucket;
    lastFolder = folder;
    return 'https://cdn.example/products/new.jpg';
  }
}

/// Mounts the product list stub and opens the Add form modal.
Future<ProductController> pumpAddForm(
  WidgetTester tester, {
  FakeProductService? service,
  Size size = const Size(390, 844),
  bool dark = false,
  bool khmer = false,
  double scale = 1,
  double keyboardInset = 0,
  bool seedEmptyLookups = false,
  bool openForm = true,
  Transition transition = Transition.noTransition,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  seedProductLookups(empty: seedEmptyLookups);
  final controller = ProductController(
    service: service ?? FakeProductService([]),
  );
  await controller.getProducts(showLoading: false);
  Get.put(controller);

  final family = khmer ? 'NotoSansKhmer' : 'NotoSans';
  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
      theme: dark
          ? AppTheme.dark(fontFamily: family)
          : AppTheme.light(fontFamily: family),
      defaultTransition: transition,
      home: const Scaffold(body: Text('home-stub')),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (openForm) {
    controller.addProduct(tester.element(find.text('home-stub')));
    await tester.pumpAndSettle();
  }
  return controller;
}

Future<void> openEditForm(
  WidgetTester tester,
  ProductController c, {
  int productId = 1,
}) async {
  await c.onEditProduct(productId, tester.element(find.text('home-stub')));
  await tester.pumpAndSettle();
}

/// Prefills controller state the way onEditProduct does after a fetch.
void prefillForEdit(
  ProductController c, {
  String name = 'Water',
  String barcode = '111',
  String cost = '2.50',
  String sale = '1.00',
  String photo = '',
}) {
  c.productNameController.text = name;
  c.productBarcodeController.text = barcode;
  c.productCostPriceController.text = cost;
  c.productSalePriceController.text = sale;
  c.productDescriptionController.text = '';
  c.productPhotoController.text = photo;
  c.selectedCategory.value = '1';
  c.selectedUnit.value = '1';
  c.selectedCurrency.value = '1';
  c.selectedWarehouse.value = null;
}

Finder fieldOf(TextEditingController c) =>
    find.byWidgetPredicate((w) => w is TextField && w.controller == c);

Finder get saveButton => find.widgetWithText(FilledButton, 'Save');
Finder get updateButton => find.widgetWithText(FilledButton, 'Update');
Finder get cancelButton => find.widgetWithText(OutlinedButton, 'Cancel');

Future<void> selectDropdown(
  WidgetTester tester,
  String hint,
  String itemText,
) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, hint));
  await tester.pumpAndSettle();
  await tester.tap(find.text(itemText).last);
  await tester.pumpAndSettle();
}

Future<void> fillValidForm(
  WidgetTester tester,
  ProductController c, {
  String name = 'Water',
  String barcode = '111',
  String cost = '2.50',
  String sale = '0',
}) async {
  await tester.enterText(fieldOf(c.productNameController), name);
  await tester.enterText(fieldOf(c.productBarcodeController), barcode);
  await selectDropdown(tester, 'Select Category', 'Drinks');
  await selectDropdown(tester, 'Select Unit', 'Pcs');
  await selectDropdown(tester, 'Select Currency', 'US Dollar');
  await tester.enterText(fieldOf(c.productCostPriceController), cost);
  await tester.enterText(fieldOf(c.productSalePriceController), sale);
  await tester.pumpAndSettle();
}

bool fieldHasFocus(WidgetTester tester, Finder field) {
  final editable = tester.widget<EditableText>(
    find.descendant(of: field, matching: find.byType(EditableText)).first,
  );
  return editable.focusNode.hasFocus;
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    locator.registerSingleton<IStorageService>(_TestStorage());
    for (final font in ['NotoSans', 'NotoSansKhmer', 'MaterialIcons-Regular']) {
      final icons = font == 'MaterialIcons-Regular';
      await (FontLoader(icons ? 'MaterialIcons' : font)
            ..addFont(rootBundle.load('fonts/$font.${icons ? 'otf' : 'ttf'}')))
          .load();
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('mobile_scanner'),
          (call) async => null,
        );
  });

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('Khmer form copy is translated and free of replacement characters', () {
    for (final key in [
      'Enter a product name.',
      'Enter a barcode.',
      'Select a category.',
      'Select a unit.',
      'Select a currency.',
      'Enter a valid price of zero or more.',
      'Could not save product. Please try again.',
      'Could not open product. Please try again.',
      'Image upload is unavailable in the browser.',
      'Cancel',
      'Update',
      'Pricing',
      'Image and description',
      'Select Currency',
      'Upload Image',
      'This is a sample description',
    ]) {
      final value = kmKH[key];
      expect(value, isNotNull, reason: 'missing km key: $key');
      expect(
        RegExp(r'[ក-៿]').hasMatch(value!),
        isTrue,
        reason: 'not translated to Khmer: $key',
      );
      expect(
        RegExp('￼|\\?{2,}').hasMatch(value),
        isFalse,
        reason: 'replacement characters in: $key',
      );
    }
  });

  testWidgets('invalid product fields never call the service', (tester) async {
    final service = FakeProductService([]);
    final controller = await pumpAddForm(tester, service: service);

    // Empty form: nothing is sent and the name error appears with focus.
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(service.updateCalls, 0);
    expect(find.text('Enter a product name.'), findsOneWidget);
    expect(
      fieldHasFocus(tester, fieldOf(controller.productNameController)),
      isTrue,
    );
    expect(tester.takeException(), isNull);

    // Name only: barcode error next.
    await tester.enterText(fieldOf(controller.productNameController), 'Water');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Enter a barcode.'), findsOneWidget);

    // Whitespace name is also invalid.
    await tester.enterText(fieldOf(controller.productNameController), '   ');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Enter a product name.'), findsOneWidget);
    await tester.enterText(fieldOf(controller.productNameController), 'Water');

    // Missing required selections, one by one.
    await tester.enterText(fieldOf(controller.productBarcodeController), '111');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Select a category.'), findsOneWidget);

    await selectDropdown(tester, 'Select Category', 'Drinks');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Select a unit.'), findsOneWidget);

    await selectDropdown(tester, 'Select Unit', 'Pcs');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Select a currency.'), findsOneWidget);

    await selectDropdown(tester, 'Select Currency', 'US Dollar');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Enter a valid price of zero or more.'), findsWidgets);

    // Alphabetic and negative prices are rejected.
    await tester.enterText(
      fieldOf(controller.productCostPriceController),
      'abc',
    );
    await tester.enterText(
      fieldOf(controller.productSalePriceController),
      '-5',
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Enter a valid price of zero or more.'), findsWidgets);

    // NaN and Infinity spellings are rejected.
    await tester.enterText(
      fieldOf(controller.productCostPriceController),
      'NaN',
    );
    await tester.enterText(
      fieldOf(controller.productSalePriceController),
      'Infinity',
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(find.text('Enter a valid price of zero or more.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add form opens in a dialog on desktop and a sheet on mobile', (
    tester,
  ) async {
    await pumpAddForm(tester, size: const Size(1440, 900));
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(ProductFormWidget), findsOneWidget);
    expect(tester.getRect(find.byType(Dialog)).center.dx, closeTo(720, 2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    Get.reset();
    await pumpAddForm(tester);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(ProductFormWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero prices and sale below cost are accepted', (tester) async {
    final service = FakeProductService([]);
    final controller = await pumpAddForm(tester, service: service);

    await fillValidForm(tester, controller, cost: '2.50', sale: '0');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(service.createCalls, 1);
    expect(service.lastCreatedData?['cost_price'], '2.50');
    expect(service.lastCreatedData?['sale_price'], '0');
    expect(tester.takeException(), isNull);

    // Edit form: sale below cost reaches the fake unchanged.
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
    service.items = [productFixture(1, 'Water')];
    final controller2 = await pumpAddForm(
      tester,
      service: service,
      openForm: false,
    );
    await openEditForm(tester, controller2);
    prefillForEdit(controller2, cost: '5.00', sale: '1.00');
    await tester.pumpAndSettle();

    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    expect(service.updateCalls, 1);
    expect(service.lastUpdatedData?['cost_price'], '5.00');
    expect(service.lastUpdatedData?['sale_price'], '1.00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('late or missing lookup selections render safely', (
    tester,
  ) async {
    final service = FakeProductService([]);
    final controller = await pumpAddForm(
      tester,
      service: service,
      seedEmptyLookups: true,
    );

    // A selected id absent from the (still empty) choices must not assert.
    controller.selectedCategory.value = '99';
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(fieldOf(controller.productNameController), 'Water');
    await tester.enterText(fieldOf(controller.productBarcodeController), '111');
    await tester.enterText(fieldOf(controller.productCostPriceController), '1');
    await tester.enterText(fieldOf(controller.productSalePriceController), '2');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Submission is blocked and the stale selection is kept, not replaced.
    expect(find.text('Select a category.'), findsOneWidget);
    expect(service.createCalls, 0);
    expect(controller.selectedCategory.value, '99');

    // Lookups arriving late render safely and stay selectable.
    Get.find<CategoryController>().categoryList.assignAll([
      {'id': 1, 'name': 'Drinks'},
    ]);
    Get.find<UnitController>().unitList.assignAll([
      {'id': 1, 'name': 'Piece', 'short_name': 'Pcs'},
    ]);
    Get.find<CurrencyController>().currencyList.assignAll([
      {'id': 1, 'name': 'US Dollar', 'symbol': r'$', 'code': 'USD'},
    ]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // '99' is still unavailable, so submission stays blocked until corrected.
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 0);
    expect(controller.selectedCategory.value, '99');

    await selectDropdown(tester, 'Select Category', 'Drinks');
    await selectDropdown(tester, 'Select Unit', 'Pcs');
    await selectDropdown(tester, 'Select Currency', 'US Dollar');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(service.createCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated save and update submit once', (tester) async {
    final service = _GatedProductService([]);
    service.gate = Completer<dynamic>();
    final controller = await pumpAddForm(tester, service: service);
    await fillValidForm(tester, controller);

    await tester.tap(saveButton);
    await tester.pump();
    expect(service.createCalls, 1);
    expect(controller.isSaving.value, isTrue);
    // Submit, Cancel, and fields are disabled while pending.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(tester.widget<OutlinedButton>(cancelButton).onPressed, isNull);
    expect(
      tester
          .widget<TextField>(fieldOf(controller.productNameController))
          .enabled,
      isFalse,
    );

    // A second tap while pending must not create another request.
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();
    expect(service.createCalls, 1);

    service.gate!.complete({'id': 9});
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormWidget), findsNothing);
    expect(controller.isSaving.value, isFalse);
    expect(tester.takeException(), isNull);

    // Same guarantee for the edit form's Update.
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
    service.items = [productFixture(1, 'Water')];
    service.gate = Completer<dynamic>();
    final controller2 = await pumpAddForm(
      tester,
      service: service,
      openForm: false,
    );
    await openEditForm(tester, controller2);
    prefillForEdit(controller2);
    await tester.pumpAndSettle();

    await tester.tap(updateButton);
    await tester.pump();
    expect(service.updateCalls, 1);
    expect(controller2.isSaving.value, isTrue);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();
    expect(service.updateCalls, 1);

    service.gate!.complete({'id': 1});
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation controls are blocked while a save is pending', (
    tester,
  ) async {
    final service = _GatedProductService([]);
    service.gate = Completer<dynamic>();
    final controller = await pumpAddForm(tester, service: service);
    await fillValidForm(tester, controller);

    await tester.tap(saveButton);
    await tester.pump();
    expect(service.createCalls, 1);

    // The form's close control is disabled while the write is pending.
    final close = find.ancestor(
      of: find.byTooltip('Close'),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(close).onPressed, isNull);

    // System back does not dismiss the form either.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProductFormWidget), findsOneWidget);
    expect(controller.isSaving.value, isTrue);

    service.gate!.complete({'id': 9});
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormWidget), findsNothing);
    expect(find.text('home-stub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pop racing a pending save cannot pop a second route', (
    tester,
  ) async {
    final service = _GatedProductService([]);
    service.gate = Completer<dynamic>();
    final controller = await pumpAddForm(
      tester,
      service: service,
      // Widen the pop window the route-currency guard protects; production
      // uses noTransition, where the same race fits inside a single frame.
      transition: Transition.fadeIn,
    );
    await fillValidForm(tester, controller);
    await tester.tap(saveButton);
    await tester.pump();
    expect(service.createCalls, 1);

    // A programmatic pop starts while the write is still pending.
    Get.back();
    await tester.pump();

    service.gate!.complete({'id': 9});
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('home-stub'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('home-stub'), findsOneWidget);
    expect(Get.currentRoute, '/');
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed create and update retain the form draft', (tester) async {
    final saleController = _CountingSaleController();
    final service = _GatedProductService([]);
    service.failNextCreate = true;
    final controller = await pumpAddForm(tester, service: service);
    Get.put<SaleController>(saleController);
    await fillValidForm(tester, controller, name: 'Water');

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(service.createCalls, 1);
    expect(find.byType(ProductFormWidget), findsOneWidget);
    expect(controller.productNameController.text, 'Water');
    expect(controller.isSaving.value, isFalse);
    expect(
      controller.formError.value,
      'Could not save product. Please try again.',
    );
    expect(find.text(controller.formError.value), findsOneWidget);

    // Retry succeeds: the stale error resets, it pops once, and it refreshes
    // the list and an open Sale screen.
    final getCallsBefore = service.getCalls;
    service.gate = Completer<dynamic>();
    await tester.tap(saveButton);
    await tester.pump();
    expect(service.createCalls, 2);
    expect(controller.formError.value, '');
    service.gate!.complete({'id': 9});
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormWidget), findsNothing);
    expect(
      find.text('Could not save product. Please try again.'),
      findsNothing,
    );
    expect(service.getCalls, greaterThan(getCallsBefore));
    expect(saleController.categoryRefreshes, 1);
    expect(tester.takeException(), isNull);

    // Same guarantee for the edit form.
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
    final failingUpdate = _GatedProductService([productFixture(1, 'Water')])
      ..failNextUpdate = true;
    final controller2 = await pumpAddForm(
      tester,
      service: failingUpdate,
      openForm: false,
    );
    await openEditForm(tester, controller2);
    prefillForEdit(controller2, name: 'Coffee');
    await tester.pumpAndSettle();

    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    expect(failingUpdate.updateCalls, 1);
    expect(find.byType(ProductFormWidget), findsOneWidget);
    expect(controller2.productNameController.text, 'Coffee');
    expect(controller2.isSaving.value, isFalse);
    expect(
      controller2.formError.value,
      'Could not save product. Please try again.',
    );
    expect(find.text(controller2.formError.value), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed edit fetch stays on detail', (tester) async {
    final service = _GatedProductService([productFixture(1, 'Water')])
      ..failFetch = true;
    final controller = await pumpProductScreen(
      tester,
      service: service,
      size: const Size(390, 844),
      realDetail: true,
    );

    await tester.tap(find.text('Water'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    // Bounded pumps: the toast snackbar is queued on a deferred job and its
    // pulsing icon defeats pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(Get.currentRoute, AppRoutes.productCardDetail);
    expect(service.fetchCalls, 1);
    expect(controller.isOpeningEdit.value, isFalse);
    expect(
      find.text('Could not open product. Please try again.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    // Flush the error snackbar timer.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.products.length, 1);
  });

  testWidgets(
    'forms stay operable across layouts, themes and keyboard insets',
    (tester) async {
      Future<void> checkScenario({
        required Size size,
        bool dark = false,
        bool khmer = false,
        double scale = 1,
        double keyboardInset = 0,
      }) async {
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        final controller = await pumpAddForm(
          tester,
          service: FakeProductService([productFixture(1, 'Water')]),
          size: size,
          dark: dark,
          khmer: khmer,
          scale: scale,
          keyboardInset: keyboardInset,
        );
        prefillForEdit(controller);

        // Locale-aware labels: the pump sets the active translations.
        final submit = find.widgetWithText(FilledButton, 'Save'.tr);
        final cancel = find.widgetWithText(OutlinedButton, 'Cancel'.tr);
        expect(submit, findsOneWidget);
        expect(cancel, findsOneWidget);
        // Submit and Cancel stay above an onscreen keyboard.
        final visibleBottom = size.height - keyboardInset;
        expect(tester.getRect(submit).bottom, lessThanOrEqualTo(visibleBottom));
        expect(tester.getRect(cancel).bottom, lessThanOrEqualTo(visibleBottom));
        expect(tester.takeException(), isNull);

        Get.back();
        await tester.pumpAndSettle();
        await openEditForm(tester, controller);
        final editSubmit = find.widgetWithText(FilledButton, 'Update'.tr);
        expect(editSubmit, findsOneWidget);
        expect(cancel, findsOneWidget);
        expect(
          tester.getRect(editSubmit).bottom,
          lessThanOrEqualTo(visibleBottom),
        );
        expect(tester.takeException(), isNull);
      }

      await checkScenario(size: const Size(390, 844));
      await checkScenario(size: const Size(1440, 900), dark: true);
      await checkScenario(size: const Size(390, 844), khmer: true, scale: 2);
      await checkScenario(size: const Size(390, 844), keyboardInset: 300);
    },
  );

  testWidgets(
    'barcode scanner result replaces the barcode and cancel keeps it',
    skip: kIsWeb,
    (tester) async {
      final controller = await pumpAddForm(tester);
      controller.productBarcodeController.text = '111';
      await tester.pumpAndSettle();

      // A nonblank trimmed result replaces the barcode.
      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pump();
      await tester.pump();
      final scannerContext = tester.element(
        find.byType(TestProductScannerPage),
      );
      Navigator.pop<String>(scannerContext, ' 123 ');
      // Bounded frames only: the scanner's scan-line animation repeats.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.productBarcodeController.text, '123');
      expect(tester.takeException(), isNull);

      // A cancelled scan retains the current barcode.
      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pump();
      await tester.pump();
      final scannerContext2 = tester.element(
        find.byType(TestProductScannerPage),
      );
      Navigator.pop<String>(scannerContext2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.productBarcodeController.text, '123');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'upload sets the photo, clears stale previews, and blocks submit while pending',
    skip: kIsWeb,
    (tester) async {
      final upload = _FakeUploadController();
      upload.imageUrl.value = 'https://cdn.example/products/old.jpg';
      Get.put<ImageUploadController>(upload);

      final controller = await pumpAddForm(tester);

      // Entering the form clears the shared preview exactly once.
      expect(upload.clearCalls, 1);
      await tester.pumpWidget(
        // Rebuild without remounting: preview must not be cleared again.
        tester.widget<GetMaterialApp>(find.byType(GetMaterialApp)),
      );
      await tester.pumpAndSettle();
      expect(upload.clearCalls, 1);

      // Uploading through the shared widget sets the photo controller.
      final uploadButton = find.widgetWithText(ElevatedButton, 'Upload Image');
      await tester.ensureVisible(uploadButton);
      await tester.pumpAndSettle();
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();
      expect(
        controller.productPhotoController.text,
        'https://cdn.example/products/new.jpg',
      );
      expect(upload.lastBucket, 'product');
      expect(upload.lastFolder, 'products');

      // A pending upload disables submission. Bounded pumps only: the upload
      // button shows a repeating progress spinner while loading.
      upload.loading.value = true;
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      upload.loading.value = false;
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('edit form preserves the current photo preview', skip: kIsWeb, (
    tester,
  ) async {
    Get.put<ImageUploadController>(_FakeUploadController());
    final controller = await pumpAddForm(
      tester,
      service: FakeProductService([
        productFixture(1, 'Water')
          ..['photo'] = 'https://cdn.example/products/old.jpg',
      ]),
      openForm: false,
    );
    controller.onEditProduct(1, tester.element(find.text('home-stub')));
    // Bounded frames only: the network-image placeholder animates forever
    // under test HTTP overrides.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final image = tester.widget<AppCachedImage>(
      find
          .descendant(
            of: find.byType(ImageUploadWidget),
            matching: find.byType(AppCachedImage),
          )
          .first,
    );
    expect(image.url, 'https://cdn.example/products/old.jpg');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'web shows an unavailable-upload message instead of an upload action',
    skip: !kIsWeb,
    (tester) async {
      final controller = await pumpAddForm(tester);
      controller.productPhotoController.text =
          'https://cdn.example/products/old.jpg';
      await tester.pumpAndSettle();

      expect(
        find.text('Image upload is unavailable in the browser.'),
        findsOneWidget,
      );
      expect(find.byType(ImageUploadWidget), findsNothing);
      expect(find.byType(AppCachedImage), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
