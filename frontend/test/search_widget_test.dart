import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('search surface follows theme and clear action is labeled', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(body: AppSearchField(title: 'Search')),
      ),
    );
    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pump(const Duration(milliseconds: 600));
    // The field fills the search bounds without a second inset surface.
    expect(
      tester.getRect(find.byType(TextField)),
      tester.getRect(find.byType(AppSearchField)),
    );
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.decoration!.border, isNull);
    final theme = Theme.of(tester.element(find.byType(TextField)));
    expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
    expect(theme.inputDecorationTheme.focusedBorder, isA<OutlineInputBorder>());
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(Get.find<SearchController>().keyword.value, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('survives the shared search controller closing', (tester) async {
    final controller = Get.put(SearchController());
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: rebuild,
            builder: (context, value, child) {
              return SearchWidget(title: 'Search');
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'water');
    await tester.pump(const Duration(milliseconds: 600));

    // GetX closes route-scoped controllers while their widgets can still be
    // mounted during a route transition.
    controller.onClose();

    rebuild.value++;
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
  });

  testWidgets('clear action empties the field and shared keyword', (
    tester,
  ) async {
    final controller = Get.put(SearchController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: SearchWidget(title: 'Search')),
      ),
    );

    await tester.enterText(find.byType(TextField), 'water');
    await tester.pump();
    expect(controller.keyword.value, 'water');

    final clear = find.byTooltip('Clear search');
    expect(clear, findsOneWidget);

    await tester.tap(clear);
    await tester.pump();

    expect(find.text('water'), findsNothing);
    expect(controller.keyword.value, '');
    expect(tester.takeException(), isNull);

    // Flush the shared keyword debounce timer before the test ends.
    await tester.pump(const Duration(milliseconds: 600));
  });
}
