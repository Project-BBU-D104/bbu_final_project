import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/themes/app_theme.dart';
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
