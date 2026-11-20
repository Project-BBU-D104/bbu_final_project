import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/sale/sale_list/sale_list_screen.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'sale_test_support.dart' show pumpSalesPage;
import 'sales_management_test_support.dart';
import 'payment_crud_test.dart' as fixtures;

void main() {
  setUpAll(
    () => locator.registerSingleton<IStorageService>(
      fixtures.FakeStorageService(),
    ),
  );
  tearDownAll(() => locator.reset());
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  tearDown(() => Get.reset());
  for (final (size, desktop, showTable) in [
    (const Size(900, 900), true, false),
    (const Size(1440, 900), true, true),
    (const Size(932, 430), false, false),
  ]) {
    for (final payment in [false, true]) {
      testWidgets(
        'management list chooses a layout at $size payment=$payment',
        (tester) async {
          if (payment) {
            Get.put(
              PaymentController(
                service: fixtures.FakeSalePaymentService(
                  payments: [fixtures.paymentFixture()],
                ),
                saleService: ManagementSaleService(),
              ),
            );
          } else {
            SaleListController.invalidateCache();
            Get.put(
              SaleListController(
                service: ManagementSaleService()
                  ..rows = [
                    {'id': 1, 'invoice_no': 'SALE-1', 'total_amount': '12.50'},
                  ],
              ),
            );
          }
          await pumpSalesPage(
            tester,
            payment ? PaymentScreen() : SaleListScreen(),
            size: size,
            desktopShell: true,
            route: payment ? '/sale-payment' : '/sale-list',
          );
          await tester.pumpAndSettle();
          expect(
            find.byWidgetPredicate((widget) => widget is AppTable),
            showTable ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(AppListCard),
            showTable ? findsNothing : findsOneWidget,
          );
          expect(
            find.byType(CustomAppBar),
            desktop ? findsNothing : findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(1440, 900),
  ]) {
    for (final dark in [false, true]) {
      for (final khmer in [false, true]) {
        for (final payment in [false, true]) {
          testWidgets(
            'management shell $size dark=$dark km=$khmer payment=$payment scale2',
            (tester) async {
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              if (payment) {
                Get.put(
                  PaymentController(
                    service: fixtures.FakeSalePaymentService(
                      payments: [fixtures.paymentFixture()],
                    ),
                    saleService: ManagementSaleService(),
                  ),
                );
              } else {
                SaleListController.invalidateCache();
                Get.put(
                  SaleListController(
                    service: ManagementSaleService()
                      ..rows = [
                        {
                          'id': 1,
                          'invoice_no': 'វិក្កយបត្រលក់វែង',
                          'total_amount': '12.50',
                          'customer': null,
                        },
                      ],
                  ),
                );
              }
              await tester.pumpWidget(
                GetMaterialApp(
                  translations: AppTranslation(),
                  locale: khmer
                      ? const Locale('km', 'KH')
                      : const Locale('en', 'US'),
                  theme: dark ? AppTheme.dark() : AppTheme.light(),
                  builder: (context, nav) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(2)),
                    child: DesktopAppShell(
                      route: payment ? '/sale-payment' : '/sale-list',
                      child: nav!,
                    ),
                  ),
                  home: payment ? PaymentScreen() : SaleListScreen(),
                ),
              );
              await tester.pumpAndSettle();
              expect(
                find.byType(CustomAppBar),
                size == const Size(1440, 900) ? findsNothing : findsOneWidget,
              );
              final desktop = size == const Size(1440, 900);
              final pageHeader = find.byType(AppPageHeader);
              if (desktop) {
                expect(
                  tester.widget<AppPageHeader>(pageHeader).leading,
                  isNotNull,
                );
              } else {
                expect(pageHeader, findsNothing);
                expect(
                  find.text((payment ? 'Payment' : 'Sale List').tr),
                  findsOneWidget,
                );
                expect(
                  find.descendant(
                    of: find.byType(CustomAppBar),
                    matching: find.byTooltip('Refresh'.tr),
                  ),
                  findsOneWidget,
                );
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
