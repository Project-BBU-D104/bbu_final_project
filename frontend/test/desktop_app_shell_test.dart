import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/main.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/home/home_screen.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';
import 'home_screen_test.dart' show FakeHomeService, TestHomeController;
import 'manage_access_test.dart' show FakeStorageService;

class TestLanguageController extends GetxController
    implements LanguageController {
  @override
  final locale = const Locale('en', 'US').obs;
  @override
  String get fontFamily => 'NotoSans';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<GetPage> originalPages;
  late FakeStorageService storage;
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    for (final font in ['NotoSans', 'NotoSansKhmer', 'MaterialIcons-Regular']) {
      final icons = font == 'MaterialIcons-Regular';
      await (FontLoader(icons ? 'MaterialIcons' : font)
            ..addFont(rootBundle.load('fonts/$font.${icons ? 'otf' : 'ttf'}')))
          .load();
    }
  });
  setUp(() {
    Get.testMode = true;
    storage = FakeStorageService();
    locator.registerSingleton<IStorageService>(storage);
    Get.put<LanguageController>(TestLanguageController());
    Get.put(ThemeController(storageService: storage));
    originalPages = List.of(AppPages.pages);
    AppPages.pages
      ..clear()
      ..addAll([
        GetPage(
          name: AppRoutes.landing,
          page: () => const Scaffold(body: Text('Startup')),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const Scaffold(body: Text('Sign in page')),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => HomeScreen(),
          binding: BindingsBuilder(() {
            Get.put<HomeController>(
              TestHomeController(
                FakeHomeService(),
                admin: storage.role == 'Admin',
              ),
            );
          }),
        ),
        GetPage(
          name: '/feature',
          page: () => const Scaffold(body: TextField(key: Key('note'))),
        ),
        GetPage(
          name: '/detail',
          page: () => const Scaffold(body: Text('Feature detail')),
        ),
      ]);
  });
  tearDown(() async {
    Get.reset();
    await locator.reset();
    AppPages.pages
      ..clear()
      ..addAll(originalPages);
  });

  Future<void> showApp(WidgetTester tester, {bool admin = false}) async {
    storage.role = admin ? 'Admin' : 'cashier';
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
  }

  testWidgets(
    'Sidebar persists through named/direct pages, back, dialogs, and resizing',
    (tester) async {
      await showApp(tester, admin: true);
      Get.offAllNamed(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final logo = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == logoPath,
      );
      expect(logo, findsOneWidget);
      expect(tester.getCenter(find.text('Profile')).dy, greaterThan(800));
      final sidebar = tester.element(find.byType(NavigationRail));

      Get.toNamed('/feature');
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(NavigationRail)), same(sidebar));
      await tester.enterText(find.byKey(const Key('note')), 'Keep this draft');
      Get.toNamed('/detail');
      await tester.pumpAndSettle();
      expect(find.text('Feature detail'), findsOneWidget);
      expect(tester.element(find.byType(NavigationRail)), same(sidebar));
      Get.back();
      await tester.pumpAndSettle();
      expect(find.text('Keep this draft'), findsOneWidget);

      Get.key.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Scanner-style page')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scanner-style page'), findsOneWidget);
      expect(tester.element(find.byType(NavigationRail)), same(sidebar));
      Get.key.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Keep this draft'), findsOneWidget);

      Get.to(() => const Scaffold(body: Text('Direct page')));
      await tester.pumpAndSettle();
      expect(find.text('Direct page'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();
      Get.dialog(const AlertDialog(content: Text('Dialog content')));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(600, 900);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Keep this draft'), findsOneWidget);
      tester.view.physicalSize = const Size(1280, 900);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Keep this draft'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.home);
      expect(find.text('Profile page'), findsOneWidget);
      expect(Get.find<HomeController>().selectedIndex.value, 4);
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(find.text('Manage page'), findsOneWidget);
      Get.offAllNamed(AppRoutes.login);
      await tester.pumpAndSettle();
      expect(find.text('Sign in page'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Direct entry can open Profile without an existing Home route', (
    tester,
  ) async {
    await showApp(tester);
    Get.offAllNamed('/feature');
    await tester.pumpAndSettle();
    expect(Get.isRegistered<HomeController>(), isFalse);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Report'), findsNothing);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.home);
    expect(find.text('Profile page'), findsOneWidget);
    expect(Get.find<HomeController>().selectedIndex.value, 3);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
