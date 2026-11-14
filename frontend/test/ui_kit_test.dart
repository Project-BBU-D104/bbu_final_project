import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/ui/app_tokens.dart';

void main() {
  group('shared theme', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final name = theme.brightness.name;

      test('$name card theme uses the shared card shape', () {
        final card = theme.cardTheme;
        expect(card.elevation, 0);
        expect(card.margin, EdgeInsets.zero);
        final shape = card.shape as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          BorderRadius.circular(AppTokens.radiusCard),
        );
        expect(
          shape.side.color,
          Color.alphaBlend(
            theme.colorScheme.onSurface.withValues(
              alpha: AppTokens.borderAlpha,
            ),
            theme.cardColor,
          ),
        );
      });

      test('$name buttons share the control radius and height', () {
        final filled = theme.filledButtonTheme.style!;
        expect(
          filled.minimumSize!.resolve({}),
          const Size(0, AppTokens.controlHeight),
        );
        expect(
          (filled.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(AppTokens.radiusControl),
        );

        final outlined = theme.outlinedButtonTheme.style!;
        expect(
          outlined.minimumSize!.resolve({}),
          const Size(0, AppTokens.controlHeight),
        );
        expect(
          (outlined.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(AppTokens.radiusControl),
        );
        expect(
          outlined.side!.resolve({})!.color,
          theme.colorScheme.onSurface.withValues(alpha: 0.12),
        );

        final icon = theme.iconButtonTheme.style!;
        expect(icon.minimumSize!.resolve({}), const Size(48, 48));
      });

      test('$name inputs use the shared field decoration', () {
        final input = theme.inputDecorationTheme;
        expect(input.filled, isTrue);
        expect(
          input.contentPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );
        expect(
          (input.border! as OutlineInputBorder).borderRadius,
          BorderRadius.circular(AppTokens.radiusControl),
        );
        final enabled = input.enabledBorder! as OutlineInputBorder;
        expect(
          enabled.borderRadius,
          BorderRadius.circular(AppTokens.radiusControl),
        );
        expect(
          enabled.borderSide.color,
          theme.colorScheme.onSurface.withValues(alpha: 0.1),
        );
        final focused = input.focusedBorder! as OutlineInputBorder;
        expect(
          focused.borderRadius,
          BorderRadius.circular(AppTokens.radiusControl),
        );
        expect(focused.borderSide.color, theme.colorScheme.primary);
        expect(focused.borderSide.width, 1.5);
        expect(
          input.fillColor,
          Color.alphaBlend(
            theme.colorScheme.onSurface.withValues(
              alpha: AppTokens.controlAlpha,
            ),
            theme.cardColor,
          ),
        );
      });

      test('$name dividers, dialogs and sheets use the shared surfaces', () {
        final line = theme.colorScheme.onSurface.withValues(
          alpha: AppTokens.borderAlpha,
        );
        expect(theme.dividerTheme.color, line);
        expect(theme.dividerColor, line);

        final dialog = theme.dialogTheme;
        expect(
          (dialog.shape! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(AppTokens.radiusSheet),
        );
        expect(theme.bottomSheetTheme.backgroundColor, theme.cardColor);
      });
    }
  });

  group('AppPage and AppPageHeader', () {
    Future<void> pumpHeader(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppPage(
              child: AppPageHeader(
                title: 'Suppliers',
                subtitle: 'Manage supplier contacts and locations.',
                actions: FilledButton(
                  onPressed: () {},
                  child: const Text('Add Supplier'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('header exposes exactly one semantic title', (tester) async {
      await pumpHeader(tester, 390);
      final headers = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.header == true)
          .toList();
      expect(headers, hasLength(1));
      expect(
        find.descendant(
          of: find.byWidget(headers.first),
          matching: find.text('Suppliers'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('page gutter is compact below 600 and wide above', (
      tester,
    ) async {
      await pumpHeader(tester, 390);
      expect(tester.getRect(find.text('Suppliers')).left, 16);
      await pumpHeader(tester, 1200);
      expect(tester.getRect(find.text('Suppliers')).left, 32);
    });

    testWidgets('actions sit beside the title on a wide page', (tester) async {
      await pumpHeader(tester, 1200);
      final title = tester.getRect(find.text('Suppliers'));
      final add = tester.getRect(
        find.widgetWithText(FilledButton, 'Add Supplier'),
      );
      expect(add.left, greaterThan(title.right));
      expect(add.top, closeTo(title.top, 24));
    });

    testWidgets('actions drop below the title on a narrow page', (
      tester,
    ) async {
      await pumpHeader(tester, 390);
      final title = tester.getRect(find.text('Suppliers'));
      final add = tester.getRect(
        find.widgetWithText(FilledButton, 'Add Supplier'),
      );
      expect(add.top, greaterThan(title.bottom));
      // Right aligned to the content edge.
      expect(add.right, closeTo(374, 0.1));
    });

    testWidgets('page content is capped at the max width and centered', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppPage(
              child: const SizedBox(key: Key('content'), width: 1400, height: 10),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      expect(rect.width, AppTokens.contentMaxWidth);
      expect(rect.center.dx, 700);
    });
  });

  group('AppTable', () {
    Future<void> pumpTable(
      WidgetTester tester,
      double width, {
      void Function(String row)? onRowTap,
    }) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppTable<String>(
              rows: const ['Alpha', 'Beta'],
              onRowTap: onRowTap,
              columns: [
                AppTableColumn<String>(
                  title: 'Supplier',
                  flex: 2,
                  builder: (_, row) => Text(row),
                ),
                AppTableColumn<String>(
                  title: 'Status',
                  width: 132,
                  builder: (_, row) => const Text('Active'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('table renders its headings rows and card chrome', (
      tester,
    ) async {
      await pumpTable(tester, 1400);
      expect(find.byType(DataTable), findsOneWidget);
      final table = tester.widget<DataTable>(find.byType(DataTable));
      expect(table.dataRowMaxHeight, lessThanOrEqualTo(76));
      expect(table.headingRowHeight, 48);
      expect(find.text('Supplier'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(
        tester.getSize(find.byType(DataTable)).width,
        closeTo(tester.getSize(find.byType(Card)).width, 2),
      );
      final theme = Theme.of(tester.element(find.byType(AppTable<String>)));
      expect(tester.widget<Card>(find.byType(Card)).color, theme.cardColor);
    });

    testWidgets('table keeps its minimum width and scrolls instead', (
      tester,
    ) async {
      await pumpTable(tester, 400);
      expect(tester.getSize(find.byType(DataTable)).width, 960);
    });

    testWidgets('tapping a row reports that row', (tester) async {
      String? tapped;
      await pumpTable(tester, 1400, onRowTap: (row) => tapped = row);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(tapped, 'Alpha');
    });
  });

  group('tokens', () {
    test('token values are pinned', () {
      expect(AppTokens.radiusCard, 16);
      expect(AppTokens.radiusControl, 12);
      expect(AppTokens.radiusPill, 10);
      expect(AppTokens.radiusSheet, 20);
      expect(AppTokens.borderAlpha, 0.08);
      expect(AppTokens.controlAlpha, 0.025);
      expect(AppTokens.controlHeight, 48);
      expect(AppTokens.contentMaxWidth, 1240);
      expect(AppTokens.gutterCompact, 16);
      expect(AppTokens.gutterWide, 32);
      expect(AppTokens.bpTable, 800);
      expect(AppTokens.bpDesktop, 840);
      expect(AppTokens.bpTwoColumn, 900);
      expect(AppTokens.bpFormPair, 560);
      expect(AppTokens.bpSearchField, 440);
      expect(AppTokens.bpMetaPair, 400);
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 12);
      expect(AppSpacing.lg, 16);
      expect(AppSpacing.xl, 20);
      expect(AppSpacing.xxl, 24);
      expect(AppSpacing.xxxl, 28);
    });
  });
}
