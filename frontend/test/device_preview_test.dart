import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app_background.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/main.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

import 'auth_screens_test.dart' show AuthLanguage;
import 'profile_controller_test.dart' show FakeStorageService;

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<LanguageController>(AuthLanguage());
    Get.put(ThemeController(storageService: FakeStorageService()));

    // Isolate root app wiring from startup authentication and API calls.
    final pages = List<GetPage>.of(AppPages.pages);
    AppPages.pages
      ..clear()
      ..add(
        GetPage(
          name: AppRoutes.landing,
          page: () => const Scaffold(body: SizedBox.expand()),
        ),
      );
    addTearDown(() {
      AppPages.pages
        ..clear()
        ..addAll(pages);
      Get.reset();
    });
  });

  for (final enabled in [true, false]) {
    testWidgets('app builds and reacts with device preview enabled=$enabled', (
      tester,
    ) async {
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
      await tester.pumpWidget(
        DevicePreview(
          enabled: enabled,
          isToolbarVisible: false,
          storage: DevicePreviewStorage.none(),
          availableLocales: const [Locale('km', 'KH')],
          builder: (_) => const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GetMaterialApp), findsOneWidget);
      expect(
        tester.widget<GetMaterialApp>(find.byType(GetMaterialApp)).locale,
        enabled ? const Locale('km', 'KH') : const Locale('en', 'US'),
      );

      Get.find<ThemeController>().isDark.value = true;
      Get.find<LanguageController>().locale.value = const Locale('km', 'KH');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final app = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(app.locale, const Locale('km', 'KH'));

      final background = tester.element(find.byType(AppBackground));
      final originalSize = MediaQuery.textScalerOf(background).scale(20);
      await Get.find<ThemeController>().setFontScale(1.3);
      await tester.pumpAndSettle();
      expect(
        MediaQuery.textScalerOf(background).scale(20),
        closeTo(originalSize * 1.3, 0.001),
      );
    });
  }
}
