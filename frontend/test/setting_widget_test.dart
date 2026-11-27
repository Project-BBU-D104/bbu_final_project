import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/screen/profile/widget/setting_widget.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_text_scale.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class FakeStorageService implements IStorageService {
  final values = <StorageKey, dynamic>{};

  @override
  T? readStorage<T>(StorageKey key) => values[key] as T?;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {
    values[key] = value;
  }

  @override
  Future<void> removeStorage(StorageKey key) async {
    values.remove(key);
  }

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {
    for (final key in keys) {
      values.remove(key);
    }
  }

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  String get appStartUpRead => '';

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}

  @override
  Map<String, dynamic> get lastUserLoginRead => {};

  @override
  String get currentUserRole => '';

  @override
  bool hasRole(String role) => false;
}

void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets('dark mode switch toggles the theme and persists it', (
    tester,
  ) async {
    final storage = FakeStorageService();
    final ctr = Get.put<ThemeController>(
      ThemeController(storageService: storage),
    );

    await tester.pumpWidget(
      Obx(
        () => GetMaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ctr.isDark.value ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(body: SingleChildScrollView(child: SettingWidget())),
        ),
      ),
    );

    expect(find.text('Push Notifications'), findsNothing);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(SettingWidget))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(SettingWidget))).brightness,
      Brightness.dark,
    );
    expect(storage.values[StorageKey.darkMode], isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(SettingWidget))).brightness,
      Brightness.light,
    );
    expect(storage.values[StorageKey.darkMode], isFalse);
  });

  testWidgets('font size updates app text and survives a restart', (
    tester,
  ) async {
    final storage = FakeStorageService();
    final controller = Get.put(ThemeController(storageService: storage));

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.25)),
            child: AppTextScale(
              controller: controller,
              child: Scaffold(
                body: SingleChildScrollView(child: SettingWidget()),
              ),
            ),
          ),
        ),
      ),
    );

    double scaledText() => MediaQuery.textScalerOf(
      tester.element(find.byType(SettingWidget)),
    ).scale(20);

    expect(controller.fontScale.value, 1.0);
    expect(scaledText(), 25);
    expect(find.text('100%'), findsOneWidget);
    final slider = find.byType(Slider);
    final sliderRect = tester.getRect(slider);
    await tester.tapAt(Offset(sliderRect.right - 1, sliderRect.center.dy));
    await tester.pumpAndSettle();
    expect(scaledText(), closeTo(32.5, 0.001));
    expect(find.text('130%'), findsOneWidget);
    expect(storage.values[StorageKey.fontScale], 1.3);

    final restored = ThemeController(storageService: storage)..onInit();
    expect(restored.fontScale.value, 1.3);

    tester.widget<Slider>(slider).onChanged!(1.0);
    await tester.pumpAndSettle();
    expect(scaledText(), 25);
    expect(storage.values[StorageKey.fontScale], 1.0);
  });

  test('invalid saved font sizes fall back to normal', () {
    final storage = FakeStorageService()..values[StorageKey.fontScale] = 'bad';
    final controller = ThemeController(storageService: storage)..onInit();
    expect(controller.fontScale.value, 1.0);
  });

  test('restores font sizes between the old preset values', () {
    final storage = FakeStorageService()..values[StorageKey.fontScale] = 1.07;
    final controller = ThemeController(storageService: storage)..onInit();
    expect(controller.fontScale.value, 1.07);
  });

  testWidgets('directory column dropdowns save separate preferences', (
    tester,
  ) async {
    final storage = FakeStorageService();
    final controller = Get.put(ThemeController(storageService: storage));
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SettingWidget())),
      ),
    );

    final manage = find.byKey(const ValueKey('Manage columns'));
    final report = find.byKey(const ValueKey('Report columns'));
    await tester.ensureVisible(manage);
    await tester.tap(manage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(report);
    await tester.tap(report);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    expect(controller.manageColumns.value, 5);
    expect(controller.reportColumns.value, 2);
    final restored = ThemeController(storageService: storage)..onInit();
    expect(restored.manageColumns.value, 5);
    expect(restored.reportColumns.value, 2);
    await restored.setManageColumns(6);
    expect(restored.manageColumns.value, 5);
  });

  testWidgets('column preferences are hidden on compact screens', (
    tester,
  ) async {
    final storage = FakeStorageService();
    final controller = Get.put(ThemeController(storageService: storage));
    await controller.setManageColumns(5);
    await controller.setReportColumns(2);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(AppTokens.bpPageGutter - 1, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SettingWidget())),
      ),
    );

    final manage = find.byKey(const ValueKey('Manage columns'));
    final report = find.byKey(const ValueKey('Report columns'));
    expect(manage, findsNothing);
    expect(report, findsNothing);
    expect(find.text('Change Password'), findsOneWidget);

    tester.view.physicalSize = const Size(AppTokens.bpPageGutter, 800);
    await tester.pumpAndSettle();
    expect(manage, findsOneWidget);
    expect(report, findsOneWidget);
    expect(tester.widget<DropdownButton<int>>(manage).value, 5);
    expect(tester.widget<DropdownButton<int>>(report).value, 2);
  });

  testWidgets('about opens and closes app information', (tester) async {
    Get.put(ThemeController(storageService: FakeStorageService()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SettingWidget())),
      ),
    );

    await tester.ensureVisible(find.text('About'));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('ePOS App'), findsOneWidget);
    expect(find.text('Inventory Management'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('ePOS App'), findsNothing);
  });
}
