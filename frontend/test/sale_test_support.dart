import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'customer_test_support.dart' show setUpCustomerTests;

Map<String, dynamic> saleProductJson(int id, String name) => {
  'id': id,
  'name': name,
  'sale_price': '5.00',
  'barcode': '12345',
  'photo': null,
};
Map<String, dynamic> saleJson(int id, {String invoice = 'SALE-1'}) => {
  'id': id,
  'invoice_no': invoice,
  'customer': {'id': 1, 'name': 'Dara'},
  'sale_items': [
    {'product': saleProductJson(1, 'Water'), 'qty': 2, 'price': '5.00'},
  ],
  'subtotal': '10.00',
  'total_amount': '12.50',
  'paid_amount': '0.00',
  'due_amount': '12.50',
  'payment_status': 'unpaid',
  'payment_method': 'Cash',
  'sale_date': '2026-11-16T00:00:00Z',
};
Map<String, dynamic> salePaymentJson(int id) => {
  'id': id,
  'sale': saleJson(1),
  'amount': '12.50',
  'payment_method': 'Cash',
  'reference_no': 'REF-1',
  'payment_date': '2026-11-16T00:00:00Z',
};

mixin ReadState {
  Object? readError;
  Completer<dynamic>? heldRead;
  Future<dynamic> read(dynamic rows) async {
    if (heldRead != null) return await heldRead!.future;
    if (readError != null) throw readError!;
    return rows;
  }
}

class SaleTestSaleService extends SaleService with ReadState {
  List<Map<String, dynamic>> sales = [], categories = [], createCalls = [];
  List<int> deleteCalls = [];
  Map<String, dynamic> createResult = saleJson(1);
  Object? createError, deleteError;
  Completer<dynamic>? heldCreate;
  @override
  Future<dynamic> getSales() => read(sales);
  @override
  Future<dynamic> getProductCategories() => read(categories);
  @override
  Future<dynamic> createSale(Map<String, dynamic> data) async {
    createCalls.add(Map.from(data));
    if (heldCreate != null) return await heldCreate!.future;
    if (createError != null) throw createError!;
    return createResult;
  }

  @override
  Future<dynamic> deleteSale(int id) async {
    deleteCalls.add(id);
    if (deleteError != null) throw deleteError!;
    return true;
  }
}

class SaleTestPaymentService extends SalePaymentService with ReadState {
  List<Map<String, dynamic>> payments = [], createCalls = [], updateCalls = [];
  List<int> deleteCalls = [];
  Object? writeError;
  Completer<dynamic>? heldWrite;
  Future<dynamic> write() async {
    if (heldWrite != null) return await heldWrite!.future;
    if (writeError != null) throw writeError!;
    return salePaymentJson(1);
  }

  @override
  Future<dynamic> getPayments() => read(payments);
  @override
  Future<dynamic> createSalePayment(Map<String, dynamic> data) {
    createCalls.add(Map.from(data));
    return write();
  }

  @override
  Future<dynamic> updateSalePayment(int id, Map<String, dynamic> data) {
    updateCalls.add({'id': id, 'data': Map.from(data)});
    return write();
  }

  @override
  Future<dynamic> deleteSalePayment(int id) {
    deleteCalls.add(id);
    return write();
  }
}

class SaleTestProductService extends ProductService with ReadState {
  List<Map<String, dynamic>> rows = [];
  @override
  Future<dynamic> getProducts() => read(rows);
}

class SaleTestCustomerService extends CustomerService with ReadState {
  List<Map<String, dynamic>> rows = [];
  @override
  Future<dynamic> getCustomers() => read(rows);
}

class SaleTestCurrencyService extends CurrencyService with ReadState {
  List<Map<String, dynamic>> rows = [];
  @override
  Future<dynamic> getCurrencies() => read(rows);
}

class SaleTestPaymentTypeService extends PaymentTypeService with ReadState {
  List<Map<String, dynamic>> rows = [];
  @override
  Future<dynamic> getPaymentTypes() => read(rows);
}

Future<void> pumpSalesPage(
  WidgetTester tester,
  Widget page, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en', 'US'),
  bool dark = false,
  double textScale = 1,
  bool desktopShell = false,
  String route = '/sale',
}) async {
  setUpCustomerTests();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslation(),
      locale: locale,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      defaultTransition: Transition.noTransition,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: desktopShell
            ? DesktopAppShell(route: route, child: child!)
            : child!,
      ),
      home: page,
    ),
  );
  await tester.pump();
}
