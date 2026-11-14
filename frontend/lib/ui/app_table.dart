import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

/// One column of an [AppTable]. The column's content stays local to the
/// screen; only the table chrome is shared.
class AppTableColumn<T> {
  const AppTableColumn({
    required this.title,
    required this.builder,
    this.flex = 1,
    this.width,
    this.secondary = false,
  });

  /// The heading, translated with `.tr`.
  final String title;

  final Widget Function(BuildContext context, T row) builder;

  /// Used when [width] is null.
  final int flex;

  /// A fixed column width when set.
  final double? width;

  /// Renders the cell content in the 12px `onSurfaceVariant` style.
  final bool secondary;

  /// A single line cell value with a tooltip for the full text.
  static Widget value(
    BuildContext context,
    String? text, {
    bool secondary = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = (text ?? '').isEmpty ? '-' : text!;
    return Tooltip(
      message: label,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: secondary ? 12 : 14,
          color: secondary ? colors.onSurfaceVariant : colors.onSurface,
        ),
      ),
    );
  }
}

/// The shared table chrome: a card, a horizontal scroll and the row metrics.
class AppTable<T> extends StatelessWidget {
  const AppTable({
    super.key,
    required this.rows,
    required this.columns,
    this.onRowTap,
  });

  final List<T> rows;
  final List<AppTableColumn<T>> columns;
  final void Function(T row)? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: AppTokens.borderAlpha);
    Widget heading(String label) => Expanded(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Theme(
        data: theme.copyWith(
          dividerColor: line,
          dividerTheme: DividerThemeData(color: line, thickness: 1),
        ),
        child: Card(
          elevation: 0,
          color: theme.cardColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            side: BorderSide(color: line),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(960, constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 76,
                columnSpacing: 20,
                horizontalMargin: 24,
                headingRowColor: WidgetStatePropertyAll(
                  Color.alphaBlend(
                    colors.onSurface.withValues(alpha: AppTokens.controlAlpha),
                    theme.cardColor,
                  ),
                ),
                headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? colors.primary.withValues(alpha: 0.035)
                      : null,
                ),
                columns: [
                  for (final column in columns)
                    DataColumn(
                      label: heading(column.title),
                      columnWidth: column.width == null
                          ? FlexColumnWidth(column.flex.toDouble())
                          : FixedColumnWidth(column.width!),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      onSelectChanged: onRowTap == null
                          ? null
                          : (_) => onRowTap!(row),
                      cells: [
                        for (final column in columns)
                          DataCell(
                            DefaultTextStyle(
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: column.secondary ? 12 : 14,
                                    color: column.secondary
                                        ? colors.onSurfaceVariant
                                        : colors.onSurface,
                                  ) ??
                                  const TextStyle(),
                              child: column.builder(context, row),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
