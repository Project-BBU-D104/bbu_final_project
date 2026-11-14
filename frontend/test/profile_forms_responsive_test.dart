import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService, FakeProfileService;

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(FakeStorageService());
    }
  });
  tearDown(Get.reset);
  for (final size in [const Size(360, 640), const Size(768, 1024), const Size(1440, 900)]) {
    for (final locale in [const Locale('en', 'US'), const Locale('km', 'KH')]) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('edit responsive $size $locale dark=$dark scale=$scale', (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final ctr = Get.put(ProfileController(service: FakeProfileService()));
            late BuildContext host;
            await tester.pumpWidget(GetMaterialApp(translations: AppTranslation(), locale: locale,
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale)), child: child!),
              home: Builder(builder: (context) { host = context; return const Scaffold(); })));
            ctr.openEditProfile(host);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (final field in find.byType(AppFormField).evaluate()) {
              final rect = tester.getRect(find.byWidget(field.widget));
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(size.width));
            }
            final email = find.byWidgetPredicate((w) => w is AppFormField && w.label == 'Email Address');
            final phone = find.byWidgetPredicate((w) => w is AppFormField && w.label == 'Phone Number');
            final innerWidth = tester.getSize(find.byType(Form)).width;
            expect(tester.getTopLeft(email).dy == tester.getTopLeft(phone).dy, innerWidth >= 560);
            for (final type in [FilledButton, OutlinedButton]) {
              final target = find.byType(type);
              await tester.ensureVisible(target);
              await tester.pumpAndSettle();
              final rect = tester.getRect(target);
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(size.width));
              expect(rect.bottom, lessThanOrEqualTo(size.height));
            }
            if (size.width == 360) {
              tester.view.viewInsets = const FakeViewPadding(bottom: 300);
              addTearDown(tester.view.resetViewInsets);
              final last = find.byWidgetPredicate((w) => w is TextField && w.controller == ctr.phoneCtrl);
              await tester.ensureVisible(last);
              await tester.showKeyboard(last);
              await tester.pumpAndSettle();
              ctr.nameCtrl.clear();
              await tester.ensureVisible(find.byType(FilledButton));
              await tester.tap(find.byType(FilledButton));
              await tester.pumpAndSettle();
              expect(find.text('Name is required'.tr), findsOneWidget);
              expect(tester.getRect(find.text('Name is required'.tr)).bottom, lessThanOrEqualTo(340));
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          });
        }
      }
    }
  }
}
