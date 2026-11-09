import 'package:flutter/material.dart';

class AppBottomSheets {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    BoxConstraints? constraints,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      constraints: constraints,
      useSafeArea: true,
      backgroundColor:
          Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).cardColor,
      builder: (_) {
        return child;
      },
    );
  }
}
