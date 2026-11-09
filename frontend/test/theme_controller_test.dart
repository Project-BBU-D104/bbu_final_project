import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/theme_controller.dart';
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

  test('missing preference falls back to light', () {
    final ctr = ThemeController(storageService: FakeStorageService());
    ctr.onInit();

    expect(ctr.isDark.value, isFalse);
  });

  test('non-bool saved value falls back to light', () {
    final storage = FakeStorageService()
      ..values[StorageKey.darkMode] = 'dark';
    final ctr = ThemeController(storageService: storage);
    ctr.onInit();

    expect(ctr.isDark.value, isFalse);
  });

  test('saved true restores dark mode', () {
    final storage = FakeStorageService()
      ..values[StorageKey.darkMode] = true;
    final ctr = ThemeController(storageService: storage);
    ctr.onInit();

    expect(ctr.isDark.value, isTrue);
  });

  testWidgets('toggling persists both values and a new controller restores',
      (tester) async {
    final storage = FakeStorageService();
    final ctr = Get.put<ThemeController>(
      ThemeController(storageService: storage),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const SizedBox(),
      ),
    );

    await ctr.toggleTheme();
    expect(ctr.isDark.value, isTrue);
    expect(storage.values[StorageKey.darkMode], isTrue);

    final restored = ThemeController(storageService: storage);
    restored.onInit();
    expect(restored.isDark.value, isTrue);

    await ctr.toggleTheme();
    expect(ctr.isDark.value, isFalse);
    expect(storage.values[StorageKey.darkMode], isFalse);

    restored.onInit();
    expect(restored.isDark.value, isFalse);
  });
}
