import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/product/product_screen.dart';
import 'package:frontend/screen/product/widget/filter_widget.dart';
import 'package:frontend/screen/product/widget/product_card_detail_widget.dart';
import 'package:frontend/screen/product/widget/product_card_widget.dart';
import 'package:frontend/screen/product/widget/product_table_widget.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

import 'product_test_support.dart';
import 'profile_widget_test.dart' show FakeStorageService;

class _TestStorage extends FakeStorageService {
  @override
  bool hasRole(String role) => false;
}

/// Fails getProducts on demand while keeping already-loaded items.
class _FlakyProductService extends FakeProductService {
  _FlakyProductService(super.items);

  bool fail = false;

  @override
  Future<dynamic> getProducts() async {
    if (fail) {
      getCalls++;
      throw Exception('network down');
    }
    return super.getProducts();
  }
}

/// Records delete calls and edit-fetch ids for the detail action tests.
class _RecordingProductService extends FakeProductService {
  _RecordingProductService(super.items);

  int deleteCalls = 0;
  int? lastFetchedId;

  @override
  Future<dynamic> deleteProduct(int id) async {
    deleteCalls++;
    return super.deleteProduct(id);
  }

  @override
  Future<dynamic> getProductById(int id) async {
    lastFetchedId = id;
    return super.getProductById(id);
  }
}

/// Mounts ProductScreen on a GetMaterialApp with the Home-group theme, locale,
/// and shell setup. Seeds the static product cache through the fake service
/// before mounting so each pump is independent of prior cache contents.
Future<ProductController> pumpProductScreen(
  WidgetTester tester, {
  required FakeProductService service,
  Size size = const Size(390, 844),
  bool dark = false,
  bool khmer = false,
  double scale = 1,
  bool shell = false,
  bool realDetail = false,
  void Function(Object? arguments)? onDetail,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final family = khmer ? 'NotoSansKhmer' : 'NotoSans';
  final controller = ProductController(service: service);
  await controller.getProducts(showLoading: false);
  Get.put(controller);

  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslation(),
      locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
      theme: dark
          ? AppTheme.dark(fontFamily: family)
          : AppTheme.light(fontFamily: family),
      defaultTransition: Transition.noTransition,
      getPages: [
        GetPage(
          name: AppRoutes.productCardDetail,
          page: () {
            onDetail?.call(Get.arguments);
            return realDetail
                ? ProductCardDetailWidget()
                : const Scaffold(body: Text('detail-stub'));
          },
        ),
        GetPage(
          name: AppRoutes.addProduct,
          page: () => const Scaffold(body: Text('add-stub')),
        ),
        GetPage(
          name: AppRoutes.editProduct,
          page: () => const Scaffold(body: Text('edit-stub')),
        ),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: shell
            ? DesktopAppShell(route: AppRoutes.product, child: child!)
            : child!,
      ),
      home: ProductScreen(),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

List<Map<String, dynamic>> twoProducts() => [
  productFixture(1, 'Water'),
  productFixture(2, 'Milk'),
];

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
  });

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('product list adapts to available width', (tester) async {
    // Available content width = view width - 2 * outer padding (32 at >= 600).
    // 823 -> 759 available: cards. 824 -> 760 available: table.
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(823, 844),
    );
    expect(find.byType(ProductCardWidget), findsWidgets);
    expect(find.byType(ProductTableWidget), findsNothing);
    expect(tester.takeException(), isNull);

    Get.reset();
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(824, 844),
    );
    expect(find.byType(ProductTableWidget), findsWidgets);
    expect(find.byType(ProductCardWidget), findsNothing);
    expect(tester.takeException(), isNull);

    // Mobile under the desktop shell: sidebar hidden, cards shown.
    Get.reset();
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(390, 844),
      shell: true,
    );
    expect(find.byType(ProductCardWidget), findsWidgets);
    expect(find.byType(SearchWidget), findsOneWidget);
    expect(find.byType(FilterWidget), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Desktop under the shell: persistent sidebar plus table presentation.
    Get.reset();
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(1440, 900),
      shell: true,
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(ProductTableWidget), findsWidgets);
    expect(find.byType(SearchWidget), findsOneWidget);
    expect(find.byType(FilterWidget), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Narrow, Khmer, 200% text scaling: controls stay reachable, no overflow.
    Get.reset();
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(390, 844),
      khmer: true,
      scale: 2,
      shell: true,
    );
    expect(find.byType(SearchWidget), findsOneWidget);
    expect(find.byType(FilterWidget), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing created date renders safely', (tester) async {
    List<Map<String, dynamic>> scenario() {
      final water = productFixture(1, 'Water')..remove('created_at');
      final milk = productFixture(2, 'Milk')..['created_at'] = 'not-a-date';
      final coffee =
          productFixture(3, 'Coffee')
            ..['currency'] = {'symbol': '៛', 'code': 'KHR'}
            ..['created_at'] = null;
      final tea = productFixture(4, 'Tea')..['currency'] = null;
      return [water, milk, coffee, tea];
    }

    await pumpProductScreen(
      tester,
      service: FakeProductService(scenario()),
      size: const Size(390, 844),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
    expect(find.byType(AppCachedImage), findsWidgets);
    // Prices equal CurrencyFormatter output for USD, KHR, and null currency.
    expect(
      find.text(CurrencyFormatter.format(1.5, {'symbol': r'$', 'code': 'USD'})),
      findsOneWidget,
    );
    expect(
      find.text(CurrencyFormatter.format(4.5, {'symbol': '៛', 'code': 'KHR'})),
      findsOneWidget,
    );
    expect(find.text(CurrencyFormatter.format(6.0, null)), findsOneWidget);

    // The table presentation handles the same data safely.
    Get.reset();
    await pumpProductScreen(
      tester,
      service: FakeProductService(scenario()),
      size: const Size(1440, 900),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsWidgets);
  });

  testWidgets('refresh failure retains products and retry', (tester) async {
    final service = _FlakyProductService(twoProducts());
    final controller = await pumpProductScreen(
      tester,
      service: service,
      size: const Size(390, 844),
    );
    expect(find.text('Water'), findsOneWidget);

    service.fail = true;
    final callsBefore = service.getCalls;
    await controller.getProducts();
    await tester.pumpAndSettle();
    // Let the error snackbar finish so it cannot intercept the Retry tap.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.getCalls, greaterThan(callsBefore));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('category sheet and search use dark surfaces', (tester) async {
    await pumpProductScreen(
      tester,
      service: FakeProductService([
        productFixture(1, 'Water'),
        productFixture(2, 'Bread', category: 'Bakery'),
      ]),
      size: const Size(390, 844),
      dark: true,
    );

    final theme = Theme.of(tester.element(find.byType(SearchWidget)));

    final searchBox = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(SearchWidget),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (searchBox.decoration! as BoxDecoration).color,
      theme.colorScheme.surface,
    );

    await tester.tap(find.byType(FilterWidget));
    await tester.pumpAndSettle();

    final title = find.text('Filter by Category');
    expect(title, findsOneWidget);
    final sheetMaterial = tester.widget<Material>(
      find.ancestor(of: title, matching: find.byType(Material)).first,
    );
    expect(sheetMaterial.color, theme.colorScheme.surface);
    expect(tester.widget<Text>(title).style?.color, theme.colorScheme.onSurface);
    expect(tester.takeException(), isNull);
  });

  testWidgets('products activate by keyboard and controls are labeled', (
    tester,
  ) async {
    final water = productFixture(1, 'Water');
    Object? detailArgs;
    await pumpProductScreen(
      tester,
      service: FakeProductService([water, productFixture(2, 'Milk')]),
      size: const Size(390, 844),
      onDetail: (arguments) => detailArgs = arguments,
    );

    expect(find.byTooltip('Add Product'), findsOneWidget);
    expect(find.byTooltip('Scan Barcode'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wa');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Clear search'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final handle = tester.ensureSemantics();
    final filterSemantics = tester.getSemantics(find.byType(FilterWidget));
    expect(filterSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(filterSemantics.label, isNotEmpty);
    handle.dispose();

    // Focus the first product card and activate it with Enter.
    final inkwell = find.descendant(
      of: find.byType(ProductCardWidget).first,
      matching: find.byType(InkWell),
    );
    expect(inkwell, findsOneWidget);
    Focus.of(tester.element(inkwell)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(detailArgs, same(water));
    expect(Get.currentRoute, AppRoutes.productCardDetail);
  });

  testWidgets('product list meets Android tap-target guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpProductScreen(
      tester,
      service: FakeProductService(twoProducts()),
      size: const Size(390, 844),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  group('product detail', () {
    const longName =
        'Premium Imported Sparkling Mineral Water Family Size 1500ml';
    const longBarcode = '12345678901234567890';

    Map<String, dynamic> longProduct() => productFixture(1, longName)
      ..['barcode'] = longBarcode;

    Future<ThemeData> openDetail(
      WidgetTester tester,
      Size size, {
      bool dark = false,
      bool khmer = false,
      double scale = 1,
    }) async {
      // Unmount the previous GetMaterialApp before resetting GetX, otherwise
      // its deferred teardown clears the freshly registered controller.
      await tester.pumpWidget(const SizedBox.shrink());
      Get.reset();
      await pumpProductScreen(
        tester,
        service: _RecordingProductService([
          longProduct(),
          productFixture(2, 'Milk'),
        ]),
        size: size,
        dark: dark,
        khmer: khmer,
        scale: scale,
        realDetail: true,
      );
      await tester.tap(find.text(longName));
      await tester.pumpAndSettle();
      return Theme.of(tester.element(find.byType(ProductCardDetailWidget)));
    }

    testWidgets('detail reflows long translated content', (tester) async {
      final detail = find.byType(ProductCardDetailWidget);

      Rect imageRect() => tester
          .getRect(
            find.descendant(of: detail, matching: find.byType(AppCachedImage))
                .first,
          );
      Rect infoRect() => tester.getRect(
        find.descendant(of: detail, matching: find.text('Product Information')),
      );

      // 899 pixels of available detail width: image stacks above information.
      await openDetail(tester, const Size(931, 900));
      expect(infoRect().top, greaterThanOrEqualTo(imageRect().bottom));
      expect(find.descendant(of: detail, matching: find.byType(Card)),
          findsWidgets);
      expect(tester.takeException(), isNull);

      // 900 pixels: image beside information.
      await openDetail(tester, const Size(932, 900));
      expect(infoRect().left, greaterThanOrEqualTo(imageRect().right));
      expect(tester.takeException(), isNull);

      // Themed surfaces follow the active theme.
      var theme = Theme.of(tester.element(detail));
      final card = tester.widget<Card>(
        find.descendant(of: detail, matching: find.byType(Card)).first,
      );
      expect(card.color, theme.cardColor);
      var scaffold = tester.widget<Scaffold>(
        find.descendant(of: detail, matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.backgroundColor, theme.scaffoldBackgroundColor);

      // Long values stay fully readable, not ellipsized.
      final nameFinder = find.descendant(of: detail, matching: find.text(longName));
      expect(nameFinder, findsOneWidget);
      expect(tester.widget<Text>(nameFinder).maxLines, isNull);
      final barcodeFinder = find.descendant(
        of: detail,
        matching: find.text(longBarcode),
      );
      expect(barcodeFinder, findsOneWidget);
      expect(tester.widget<Text>(barcodeFinder).maxLines, isNull);

      // Dark, Khmer, 200% scaling on a narrow screen: nothing overflows and
      // the footer actions stay reachable.
      theme = await openDetail(
        tester,
        const Size(390, 844),
        dark: true,
        khmer: true,
        scale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(
        find.descendant(of: detail, matching: find.byType(ElevatedButton)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detail, matching: find.byType(OutlinedButton)),
        findsOneWidget,
      );
      scaffold = tester.widget<Scaffold>(
        find.descendant(of: detail, matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.backgroundColor, theme.scaffoldBackgroundColor);
      final khmerName = find.descendant(of: detail, matching: find.text(longName));
      expect(khmerName, findsOneWidget);
      expect(tester.widget<Text>(khmerName).maxLines, isNull);
    });

    testWidgets('detail tolerates absent optional fields', (tester) async {
      final product =
          productFixture(1, 'Water')
            ..['unit'] = null
            ..['category'] = null
            ..['currency'] = null
            ..['photo'] = null
            ..['description'] = null
            ..['created_at'] = null;

      await pumpProductScreen(
        tester,
        service: _RecordingProductService([product]),
        size: const Size(390, 844),
        realDetail: true,
      );
      await tester.tap(find.text('Water'));
      await tester.pumpAndSettle();

      final detail = find.byType(ProductCardDetailWidget);
      final theme = Theme.of(tester.element(detail));
      expect(tester.takeException(), isNull);
      // Unit and category fall back to '-'.
      expect(find.descendant(of: detail, matching: find.text('-')),
          findsNWidgets(2));
      expect(
        find.descendant(
          of: detail,
          matching: find.text(CurrencyFormatter.format(1.5, null)),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: detail,
          matching: find.text('No description available.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detail, matching: find.byType(AppCachedImage)),
        findsWidgets,
      );
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: detail, matching: find.byType(Scaffold)).first,
      );
      expect(scaffold.backgroundColor, theme.scaffoldBackgroundColor);
    });

    testWidgets('detail actions preserve product navigation and confirmation', (
      tester,
    ) async {
      final product = productFixture(1, 'Water');
      final service = _RecordingProductService([
        product,
        productFixture(2, 'Milk'),
      ]);
      final controller = await pumpProductScreen(
        tester,
        service: service,
        size: const Size(390, 844),
        realDetail: true,
      );
      await tester.tap(find.text('Water'));
      await tester.pumpAndSettle();

      final detail = find.byType(ProductCardDetailWidget);
      expect(Get.find<ProductController>(), same(controller));
      expect(
        find.descendant(of: detail, matching: find.text('Water')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detail, matching: find.byType(AppCachedImage)),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);

      // Delete then Cancel sends no delete request and stays on detail.
      await tester.tap(
        find.descendant(of: detail, matching: find.text('Delete')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(service.deleteCalls, 0);
      expect(Get.currentRoute, AppRoutes.productCardDetail);

      // Edit fetches the same id and passes an int to /edit-product.
      await tester.tap(
        find.descendant(of: detail, matching: find.text('Edit')),
      );
      await tester.pumpAndSettle();
      expect(service.lastFetchedId, product['id']);
      expect(Get.currentRoute, '/edit-product');
      expect(Get.arguments, product['id']);
      expect(Get.arguments, isA<int>());
    });
  });
}
