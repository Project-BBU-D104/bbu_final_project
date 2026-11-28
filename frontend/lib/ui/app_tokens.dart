import 'dart:ui' show Color;

/// Single source of truth for the app's look values.
///
/// Screens must not hardcode radii, colours, spacing, control sizes or
/// breakpoints: take them from here (or let `AppTheme` supply them).
class AppTokens {
  const AppTokens._();
  static const double saleProductTileMaxExtent = 240;
  static const double saleProductTileAspectRatio = 0.78;
  static const double saleProductThumbnailSize = 64;
  static const double saleGridMinTileWidth = 120;
  static const double saleGridImageHeight = 96;
  static const int saleGridMaxColumns = 4;

  /// Elevation of the floating sale checkout action.
  static const double saleFooterElevation = 6;

  /// Receipt confirmation presentation.
  static const double receiptContentMaxWidth = 560;
  static const double successMarkSize = 80;
  static const double successMarkIconSize = 44;
  static const double successMarkInitialScale = 0.65;
  static const Duration successMarkDuration = Duration(milliseconds: 650);
  static const Color successMarkLightBackground = Color(0xffdef5e5);
  static const Color successMarkLightForeground = Color(0xff137a40);
  static const Color successMarkDarkBackground = Color(0xff123c29);
  static const Color successMarkDarkForeground = Color(0xff8ce7af);

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

  static const double bpPageGutter = 600;

  /// Page gutter at 600px and above.
  static const double gutterWide = 32;

  /// Cards below this width, table at or above it.
  static const double bpTable = 800;

  /// Minimum width of the table surface before horizontal scrolling.
  static const double tableMinWidth = 960;

  /// Desktop shell, and dialog instead of bottom sheet.
  static const double bpDesktop = 840;

  /// Minimum viewport height for the desktop sidebar on Sales routes.
  static const double bpSaleShellMinHeight = 480;

  /// Two column detail layouts.
  static const double bpTwoColumn = 900;

  /// Two fields side by side.
  static const double bpFormPair = 560;

  /// Search field max width.
  static const double bpSearchField = 440;

  /// Two meta fields side by side.
  static const double bpMetaPair = 400;

  /// Minimum width of a directory card before reducing the column count.
  static const double featureCardMinWidth = 200;
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
