import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/dashboard_controller.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:frontend/controllers/manage_controller.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/controllers/report_controller.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/localization/km_kh.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/dashboard/dashboard_screen.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/home_screen.dart';
import 'package:frontend/screen/home/home_content.dart';
import 'package:frontend/screen/manage/manage_screen.dart';
import 'package:frontend/screen/profile/profile_screen.dart';
import 'package:frontend/screen/profile/widget/setting_widget.dart';
import 'package:frontend/screen/report/report_screen.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/widget/card_feature_widget.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeProfileService, FakeStorageService;
import 'home_screen_test.dart' show FakeHomeService;

class HomeGroupStorage extends FakeStorageService {
  @override
  String get currentUserRole => 'Admin';
  @override
  bool hasRole(String role) => role.toLowerCase() == 'admin';
}

class HomeGroupLanguage extends GetxController implements LanguageController {
  @override
  final locale = const Locale('en', 'US').obs;
  @override
  String get fontFamily =>
      locale.value.languageCode == 'km' ? 'NotoSansKhmer' : 'NotoSans';
  @override
  void changeLanguage(String code) {
    locale.value = code == 'km'
        ? const Locale('km', 'KH')
        : const Locale('en', 'US');
    Get.updateLocale(locale.value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class HomeGroupDashboard extends DashboardController {
  HomeGroupDashboard() {
    kpiData.assignAll({
      'total_stock_value': 12345.67,
      'low_stock_alerts': 2,
      'stock_movement': 17,
    });
    monthlySaleList.assignAll([
      {'sale_month': 10, 'sale_year': 2026, 'amount': 1200},
      {'sale_month': 11, 'sale_year': 2026, 'amount': 1800},
    ]);
    revenueByCategory.assignAll([
      {'category': 'Drinks', 'amount': 1200},
      {'category': 'Snacks', 'amount': 600},
    ]);
    lowstockProducts.assignAll([
      {'id': 1, 'product_name': 'Arabica coffee beans', 'stock_quantity': 2.5},
    ]);
    topProducts.assignAll([
      {
        'product_id': 1,
        'product_name': 'Arabica coffee beans',
        'total_sold': 12,
        'total_revenue': 450.75,
      },
    ]);
  }
  int refreshes = 0;
  @override
  // The fixture supplies data without starting network requests.
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> getDashboardData() async {
    refreshes++;
    errorMessage.value = '';
    isLoading.value = false;
  }
}

Future<void> pumpHomeGroupTab(
  WidgetTester tester,
  Widget tab, {
  Size size = const Size(1280, 900),
  bool dark = false,
  bool khmer = false,
  double scale = 1,
  GlobalKey? screenshotKey,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final family = khmer ? 'NotoSansKhmer' : 'NotoSans';
  final pages = [
    AppRoutes.product,
    AppRoutes.saleReport,
    AppRoutes.salePaymentReport,
    AppRoutes.purchaseReport,
    AppRoutes.purchasePaymentReport,
    AppRoutes.stockLedgerReport,
    AppRoutes.profitAndLossReport,
    AppRoutes.login,
  ];
  await tester.pumpWidget(
    RepaintBoundary(
      key: screenshotKey,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppTranslation(),
        locale: khmer ? const Locale('km', 'KH') : const Locale('en', 'US'),
        theme: dark
            ? AppTheme.dark(fontFamily: family)
            : AppTheme.light(fontFamily: family),
        defaultTransition: Transition.noTransition,
        getPages: [
          for (final route in pages)
            GetPage(
              name: route,
              page: () => Scaffold(body: Text('Opened $route')),
            ),
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: DesktopAppShell(route: '/home', child: child!),
        ),
        home: Scaffold(body: tab),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late HomeGroupDashboard dashboard;
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    locator.registerSingleton<IStorageService>(HomeGroupStorage());
    for (final font in ['NotoSans', 'NotoSansKhmer', 'MaterialIcons-Regular']) {
      final icons = font == 'MaterialIcons-Regular';
      await (FontLoader(icons ? 'MaterialIcons' : font)
            ..addFont(rootBundle.load('fonts/$font.${icons ? 'otf' : 'ttf'}')))
          .load();
    }
  });
  setUp(() {
    Get.testMode = true;
    dashboard =
        Get.put<DashboardController>(HomeGroupDashboard())
            as HomeGroupDashboard;
    Get.put<ProfileController>(
      ProfileController(service: FakeProfileService()),
    );
    Get.put(ThemeController(storageService: locator<IStorageService>()));
    Get.put<LanguageController>(HomeGroupLanguage());
  });
  tearDown(() {
    Get.reset();
  });

  final tabs = <String, Widget Function()>{
    'Dashboard': () => const DashboardScreen(),
    'Manage': () => ManageScreen(),
    'Report': () => ReportScreen(),
    'Profile': () => ProfileScreen(),
  };

  test('Home-group Khmer translations preserve Unicode text', () {
    for (final entry in kmKH.entries) {
      expect(
        RegExp(r'\?{2,}|\uFFFD').hasMatch(entry.value),
        isFalse,
        reason: entry.key,
      );
    }
    for (final key in [
      'Home',
      'Dashboard',
      'Manage',
      'Report',
      'Profile',
      'Sale Report',
      'Personal information',
    ]) {
      expect(
        RegExp(r'[\u1780-\u17FF]').hasMatch(kmKH[key]!),
        isTrue,
        reason: key,
      );
    }
  });
  for (final entry in tabs.entries) {
    for (final scenario in [
      (size: const Size(375, 812), dark: false, khmer: false, scale: 1.0),
      (size: const Size(320, 640), dark: true, khmer: true, scale: 2.0),
      (size: const Size(1280, 900), dark: true, khmer: false, scale: 1.0),
      (size: const Size(900, 375), dark: false, khmer: true, scale: 2.0),
    ]) {
      testWidgets(
        '${entry.key} fits ${scenario.size}, Khmer ${scenario.khmer}, scale ${scenario.scale}',
        (tester) async {
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await pumpHomeGroupTab(
            tester,
            entry.value(),
            size: scenario.size,
            dark: scenario.dark,
            khmer: scenario.khmer,
            scale: scenario.scale,
          );
          expect(tester.takeException(), isNull);
          final scroll = find
              .descendant(
                of: find.byType(
                  entry.key == 'Dashboard'
                      ? DashboardScreen
                      : entry.key == 'Manage'
                      ? ManageScreen
                      : entry.key == 'Report'
                      ? ReportScreen
                      : ProfileScreen,
                ),
                matching: find.byType(SingleChildScrollView),
              )
              .first;
          await tester.drag(scroll, const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Manage and Report searches are independent, support clear, and navigate',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final manage = Get.put(ManageController());
      final report = Get.put(ReportController());
      await pumpHomeGroupTab(tester, ManageScreen());
      await tester.enterText(find.byType(TextField), 'Product');
      await tester.pump();
      expect(manage.filteredSections, hasLength(1));
      expect(report.searchCtr.keyword.value, isEmpty);
      await tester.tap(find.widgetWithText(CardFeatureWidget, 'Product'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.product);
      Get.back();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'no-such-feature');
      await tester.pump();
      expect(find.text('No matching results'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(manage.filteredSections.length, greaterThan(1));
      await pumpHomeGroupTab(tester, ReportScreen());
      for (final section in report.sections) {
        for (final item in section['items'] as List) {
          report.searchCtr.textController.text = item['title'];
          await tester.pump();
          final card = find.widgetWithText(CardFeatureWidget, item['title']);
          await tester.ensureVisible(card);
          await tester.tap(card);
          await tester.pumpAndSettle();
          expect(Get.currentRoute, item['route']);
          Get.back();
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Dashboard exposes refresh, loading, safe failure, retry, and empty states',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpHomeGroupTab(tester, const DashboardScreen());
      expect(find.text('12,345.67'), findsOneWidget);
      expect(find.textContaining('\$'), findsNothing);
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(dashboard.refreshes, 1);
      dashboard.errorMessage.value = 'private backend stack trace';
      await tester.pump();
      expect(
        find.text('Showing previously loaded data. Please try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('private backend'), findsNothing);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(dashboard.refreshes, 2);
      dashboard.kpiData.clear();
      dashboard.monthlySaleList.clear();
      dashboard.revenueByCategory.clear();
      dashboard.lowstockProducts.clear();
      dashboard.topProducts.clear();
      dashboard.isLoading.value = true;
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      dashboard.isLoading.value = false;
      await tester.pumpAndSettle();
      expect(find.text('No sales data yet'), findsOneWidget);
      expect(find.text('No category revenue yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'All five real tabs work together inside the persistent Home shell',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final home = Get.put(HomeController(homeService: FakeHomeService()));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light(fontFamily: 'NotoSans'),
          initialRoute: AppRoutes.home,
          getPages: [GetPage(name: AppRoutes.home, page: () => HomeScreen())],
          builder: (context, child) =>
              DesktopAppShell(route: AppRoutes.home, child: child!),
        ),
      );
      await tester.pumpAndSettle();
      for (final tab in [
        (label: 'Dashboard', index: 1, type: DashboardScreen),
        (label: 'Manage', index: 2, type: ManageScreen),
        (label: 'Report', index: 3, type: ReportScreen),
        (label: 'Profile', index: 4, type: ProfileScreen),
        (label: 'Home', index: 0, type: HomeContent),
      ]) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text(tab.label),
          ),
        );
        await tester.pumpAndSettle();
        expect(home.selectedIndex.value, tab.index);
        expect(find.byType(tab.type), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(dashboard.refreshes, 1);
    },
  );

  testWidgets('Profile logout action opens sign-in', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpHomeGroupTab(tester, ProfileScreen());
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.login);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile language action changes the active locale', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpHomeGroupTab(tester, ProfileScreen());
    final action = find.descendant(
      of: find.byType(SettingWidget),
      matching: find.text('Language'),
    );
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('ខ្មែរ'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(Get.find<LanguageController>().locale.value.languageCode, 'km');
    expect(Get.locale?.languageCode, 'km');
    expect(tester.takeException(), isNull);
  });
}
