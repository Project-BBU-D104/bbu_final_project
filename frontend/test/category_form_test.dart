import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/category_screen.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:get/get.dart';
import 'category_test_support.dart';

void main() {
  setUp(setUpCategoryTests);
  tearDown(Get.reset);

  Future<CategoryController> seed(
    WidgetTester tester,
    FakeCategoryService service,
  ) async {
    final c = CategoryController(service: service);
    await c.getCategory();
    Get.put<CategoryController>(c);
    await pumpCategoryHost(tester, home: CategoryScreen());
    return c;
  }

  void fill(CategoryController c) {
    c.nameController.text = ' Alpha ';
    c.descriptionController.text = ' Everyday goods ';
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('blank name never writes', (tester) async {
    final s = FakeCategoryService();
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Category name is required'), findsOneWidget);
    c.nameController.text = '  ';
    await c.onSaveCategory(tester.element(find.byType(AddCategoryWidget)));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
  });

  testWidgets('trimmed payload keeps the category contract', (tester) async {
    final s = FakeCategoryService();
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(s.lastCreatedData, {
      'name': 'Alpha',
      'description': 'Everyday goods',
    });
    expect(s.createCalls, 1);
    expect(find.byType(AddCategoryWidget), findsNothing);
  });

  testWidgets('write failure preserves the draft and shows an error', (
    tester,
  ) async {
    final s = FakeCategoryService()..failWrite = true;
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(c.nameController.text, ' Alpha ');
    expect(find.byType(AddCategoryWidget), findsOneWidget);
    expect(
      find.text('Unable to save category. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = DelayedCategoryService();
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final context = tester.element(find.byType(AddCategoryWidget));
    c.onSaveCategory(context);
    c.onSaveCategory(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddCategoryWidget), findsOneWidget);
    s.create.complete(categoryJson(3, 'Alpha'));
    await tester.pumpAndSettle();
    expect(find.byType(AddCategoryWidget), findsNothing);
  });

  testWidgets('edit updates the list and keeps the route', (tester) async {
    final s = FakeCategoryService();
    final c = await seed(tester, s);
    await c.onEditCategory(1, tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(EditCategoryWidget), findsOneWidget);
    c.nameController.text = 'Updated';
    await save(tester);
    expect(find.byType(EditCategoryWidget), findsNothing);
    expect(find.byType(CategoryScreen), findsOneWidget);
    expect(c.categoryList.first['name'], 'Updated');
    c.searchCategory('updated');
    expect(c.searchCategoryList.length, 1);
  });

  testWidgets('refresh failure after a committed save keeps the new row', (
    tester,
  ) async {
    final s = FakeCategoryService();
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    fill(c);
    s.failGet = true;
    await save(tester);
    expect(s.createCalls, 1);
    expect(
      c.categoryList.any((e) => e['name'] == 'Alpha' && e['id'] == 3),
      isTrue,
    );
    expect(find.byType(AddCategoryWidget), findsNothing);
    expect(c.loadError.value, isNotEmpty);
  });

  testWidgets('late edit fetch never opens on another page', (tester) async {
    final s = DelayedCategoryService();
    final c = await seed(tester, s);
    final ctx = tester.element(find.byType(CategoryScreen));
    c.onEditCategory(1, ctx);
    c.onEditCategory(1, ctx);
    Get.to(() => const Scaffold(body: Text('Other')));
    await tester.pumpAndSettle();
    s.edit.complete(categoryJson(1, 'Late'));
    await tester.pumpAndSettle();
    expect(s.getByIdCalls, 1);
    expect(find.byType(EditCategoryWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete cancel, failure, and success preserve the list route', (
    tester,
  ) async {
    final s = FakeCategoryService();
    final c = await seed(tester, s);
    Future<void> openDelete() async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
    }

    await openDelete();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 0);
    s.failWrite = true;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryScreen), findsOneWidget);
    expect(c.categoryList.length, 2);
    s.failWrite = false;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryScreen), findsOneWidget);
    expect(c.categoryList.map((e) => e['id']), [2]);
  });

  testWidgets('failed update preserves the draft and blank names never write', (
    tester,
  ) async {
    final s = FakeCategoryService()..failWrite = true;
    final c = await seed(tester, s);
    await c.onEditCategory(1, tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    c.nameController.text = 'Changed';
    await save(tester);
    expect(c.nameController.text, 'Changed');
    expect(find.byType(EditCategoryWidget), findsOneWidget);
    c.nameController.text = ' ';
    await c.onUpdateCategory(
      1,
      tester.element(find.byType(EditCategoryWidget)),
    );
    expect(s.updateCalls, 1);
  });

  testWidgets('form survives keyboard, Khmer, and large text', (tester) async {
    final c = await seed(tester, FakeCategoryService());
    await pumpCategoryHost(
      tester,
      home: CategoryScreen(),
      locale: const Locale('km', 'KH'),
      dark: true,
      textScale: 2,
    );
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'.tr));
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller disposal during a write never pops another page', (
    tester,
  ) async {
    final s = DelayedCategoryService();
    final c = await seed(tester, s);
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final pending = c.onSaveCategory(
      tester.element(find.byType(AddCategoryWidget)),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    Get.delete<CategoryController>(force: true);
    s.create.complete(categoryJson(3, 'Alpha'));
    await pending;
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop form opens as a dialog', (tester) async {
    final c = await seed(tester, FakeCategoryService());
    await pumpCategoryHost(
      tester,
      home: CategoryScreen(),
      size: const Size(1440, 900),
    );
    c.addCategory(tester.element(find.byType(CategoryScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AddCategoryWidget), findsOneWidget);
  });
}