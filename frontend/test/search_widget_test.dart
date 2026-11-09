import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('search surface follows theme and clear action is labeled', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: SearchWidget(title: 'Search')),
      ),
    );
    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pump(const Duration(milliseconds: 600));
    final decoration =
        tester
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.byType(TextField),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(
      decoration.color,
      Theme.of(tester.element(find.byType(TextField))).colorScheme.surface,
    );
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
      const GetMaterialApp(home: Scaffold(body: SearchWidget(title: 'Search'))),
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
