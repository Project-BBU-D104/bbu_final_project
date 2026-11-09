import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/home/home_content.dart';
import 'package:frontend/screen/home/home_screen.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/recent_orders_widget.dart';
import 'package:frontend/services/main_service/home_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';
import 'manage_access_test.dart' show FakeStorageService;

class FakeHomeService extends HomeService {
  bool fail = false;
  Completer<dynamic>? gate;
  @override
  Future<dynamic> getRecentSales() async {
    if (fail) throw StateError('private server error');
    return gate?.future ??
        [
          {'invoice_no': 'SALE-001', 'subtotal': 45, 'sale_date': '2026-11-09'},
        ];
  }

  @override
  Future<dynamic> getRecentPrucases() async {
    if (fail) throw StateError('private server error');
    return gate?.future ??
        [
          {
            'invoice_no': 'PO-001',
            'supplier_name': 'Test supplier',
            'qty': 3,
            'subtotal': 120,
            'purchase_date': '2026-11-09',
          },
        ];
  }
}

class TestHomeController extends HomeController {
  TestHomeController(FakeHomeService service, {this.admin = false})
    : super(homeService: service);
  final bool admin;
  int? tapped;
  @override
  bool get canViewReport => admin;
  @override
  void onWelcome() => welcomePage.value = {'name': 'Alex', 'photo': ''};
  @override
  List<Widget> get tabPages => [
    const HomeContent(),
    const Text('Dashboard page'),
    const Text('Manage page'),
    if (admin) const Text('Report page'),
    const Text('Profile page'),
  ];
  @override
  void onTabChanged(int index) {
    tapped = index;
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void gotoSale() => tapped = 10;
  @override
  void gotoCategory() => tapped = 11;
  @override
  void gotoProduct() => tapped = 12;
  @override
  void gotoSupplier() => tapped = 13;
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    for (final family in ['NotoSans', 'NotoSansKhmer']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('fonts/$family.ttf'))).load();
    }
  });
  setUp(() {
    Get.testMode = true;
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(FakeStorageService());
    }
  });
  tearDown(() async {
    Get.reset();
    await locator.reset();
  });

  Future<TestHomeController> showHome(
    WidgetTester tester, {
    Size size = const Size(375, 812),
    bool dark = false,
    bool khmer = false,
    double scale = 1,
    bool admin = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller =
        Get.put<HomeController>(
              TestHomeController(FakeHomeService(), admin: admin),
            )
            as TestHomeController;
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
        theme: dark
            ? AppTheme.dark(fontFamily: khmer ? 'NotoSansKhmer' : 'NotoSans')
            : AppTheme.light(fontFamily: khmer ? 'NotoSansKhmer' : 'NotoSans'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: DesktopAppShell(route: '/home', child: child!),
        ),
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  for (final scenario in [
    (size: const Size(320, 640), scale: 2.0, khmer: false, dark: false),
    (size: const Size(375, 812), scale: 1.0, khmer: false, dark: false),
    (size: const Size(375, 812), scale: 2.0, khmer: true, dark: true),
    (size: const Size(1280, 900), scale: 1.0, khmer: false, dark: true),
    (size: const Size(900, 375), scale: 2.0, khmer: true, dark: false),
  ]) {
    testWidgets(
      'Home fits ${scenario.size} scale ${scenario.scale} Khmer ${scenario.khmer}',
      (tester) async {
        await showHome(
          tester,
          size: scenario.size,
          scale: scenario.scale,
          khmer: scenario.khmer,
          dark: scenario.dark,
          admin: true,
        );
        expect(find.text('Alex'), findsOneWidget);
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -1500),
        );
        await tester.pumpAndSettle();
        expect(find.text('SALE-001'), findsOneWidget);
        expect(find.text('PO-001'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Home actions and role-gated navigation work', (tester) async {
    final controller = await showHome(tester);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    await tester.tap(find.text('New sale'));
    expect(controller.tapped, 10);
    for (final action in [
      ('Sale', 10),
      ('Category', 11),
      ('Product', 12),
      ('Supplier', 13),
    ]) {
      await tester.ensureVisible(find.text(action.$1));
      await tester.tap(find.text(action.$1));
      expect(controller.tapped, action.$2);
    }
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Profile page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Recent order states expose retry and view all controls', (
    tester,
  ) async {
    var retries = 0;
    var views = 0;
    Future<void> showOrders({bool loading = false, bool hasError = false}) =>
        tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: RecentOrdersWidget(
                title: 'Recent Sale Order',
                items: const [],
                isPurchase: false,
                loading: loading,
                hasError: hasError,
                onRetry: () => retries++,
                onViewAll: () => views++,
              ),
            ),
          ),
        );
    await showOrders(loading: true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No Data'), findsNothing);
    await showOrders(hasError: true);
    expect(find.text('Unable to load orders'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
    await showOrders();
    expect(find.text('No Data'), findsOneWidget);
    await tester.tap(find.text('View All'));
    expect(views, 1);
  });

  test(
    'Recent orders distinguish loading, failure, retry, and empty results',
    () async {
      final service = FakeHomeService()..gate = Completer<dynamic>();
      final controller = HomeController(homeService: service);
      final sales = controller.getRecentSale();
      expect(controller.salesLoading.value, isTrue);
      service.gate!.complete([]);
      await sales;
      expect(controller.salesLoading.value, isFalse);
      expect(controller.recentSaleList, isEmpty);
      service.fail = true;
      await Future.wait([
        controller.getRecentSale(),
        controller.getRecentPurchase(),
      ]);
      expect(controller.salesError.value, isTrue);
      expect(controller.purchasesError.value, isTrue);
      service.fail = false;
      service.gate = null;
      await Future.wait([
        controller.getRecentSale(),
        controller.getRecentPurchase(),
      ]);
      expect(controller.salesError.value, isFalse);
      expect(controller.purchasesError.value, isFalse);
      expect(controller.recentSaleList.single['invoice_no'], 'SALE-001');
      expect(controller.recentPurchaseList.single['invoice_no'], 'PO-001');
      controller.onClose();
    },
  );
}
