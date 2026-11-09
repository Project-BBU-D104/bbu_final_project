import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/screen/profile/widget/setting_widget.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
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

  testWidgets('dark mode switch toggles the theme and persists it',
      (tester) async {
    final storage = FakeStorageService();
    final ctr = Get.put<ThemeController>(
      ThemeController(storageService: storage),
    );

    await tester.pumpWidget(
      Obx(
        () => GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ctr.isDark.value ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(body: SettingWidget()),
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
}
