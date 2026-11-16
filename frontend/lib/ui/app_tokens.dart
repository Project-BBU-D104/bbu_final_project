/// Single source of truth for the app's look values.
///
/// Screens must not hardcode radii, colours, spacing, control sizes or
/// breakpoints: take them from here (or let `AppTheme` supply them).
class AppTokens {
  const AppTokens._();

  static const double formMaxHeightFactor = 0.9;

  static const double tableMaxScaledBodySize = 20.8;

  /// Cards, tables and list rows.
  static const double radiusCard = 16;

  /// Buttons, inputs, icon boxes.
  static const double radiusControl = 12;

  /// Status pills.
  static const double radiusPill = 10;

  /// Bottom sheets, dialogs and section cards.
  static const double radiusSheet = 20;

  /// Card outline and divider.
  static const double borderAlpha = 0.08;

  /// Input fill blend on the card colour.
  static const double controlAlpha = 0.025;

  /// Every button and icon button.
  static const double controlHeight = 48;

  /// Widest the page content may grow.
  static const double contentMaxWidth = 1240;

  /// Page gutter below 600px.
  static const double gutterCompact = 16;

  /// Page gutter at 600px and above.
  static const double gutterWide = 32;

  /// Cards below this width, table at or above it.
  static const double bpTable = 800;

  /// Desktop shell, and dialog instead of bottom sheet.
  static const double bpDesktop = 840;

  /// Two column detail layouts.
  static const double bpTwoColumn = 900;

  /// Two fields side by side.
  static const double bpFormPair = 560;

  /// Search field max width.
  static const double bpSearchField = 440;

  /// Two meta fields side by side.
  static const double bpMetaPair = 400;
}

/// Spacing scale. Screens use these instead of literal gaps.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
}
