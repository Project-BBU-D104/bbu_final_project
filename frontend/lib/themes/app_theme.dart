import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';

/// The app's single source of look. Screens inherit these component themes;
/// structural pieces live in `package:frontend/ui/`.
class AppTheme {
  static ThemeData light({String? fontFamily}) => _build(
    fontFamily: fontFamily,
    brightness: Brightness.light,
    primaryColor: const Color(0xff007bff),
    scaffoldBackgroundColor: const Color(0xfff5f5f5),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xff0064d2),
      onPrimary: Colors.white,
      primaryContainer: Color(0xff003e80),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xffffc107),
      surface: Colors.white,
    ),
  );

  static ThemeData dark({String? fontFamily}) => _build(
    fontFamily: fontFamily,
    brightness: Brightness.dark,
    primaryColor: const Color(0xff007bff),
    scaffoldBackgroundColor: const Color(0xff121212),
    cardColor: const Color(0xff1e1e1e),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff80b6ff),
      onPrimary: Color(0xff002e69),
      primaryContainer: Color(0xff003e80),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xffffc107),
      surface: Color(0xff1e1e1e),
    ),
  );

  static ThemeData _build({
    required String? fontFamily,
    required Brightness brightness,
    required Color primaryColor,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
    required ColorScheme colorScheme,
  }) {
    final base = ThemeData(
      fontFamily: fontFamily,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      colorScheme: colorScheme,
    );
    final colors = base.colorScheme;
    final line = colors.onSurface.withValues(alpha: AppTokens.borderAlpha);
    const controlShape = WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusControl)),
      ),
    );
    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: BorderSide(color: Color.alphaBlend(line, cardColor)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(0, AppTokens.controlHeight),
          ),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppTokens.controlHeight),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.onSurface.withValues(alpha: 0.12)),
          ),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(0, AppTokens.controlHeight),
          ),
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: const ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          shape: controlShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.alphaBlend(
          colors.onSurface.withValues(alpha: AppTokens.controlAlpha),
          cardColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          borderSide: BorderSide(color: colors.onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1),
      dividerColor: line,
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSheet),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
