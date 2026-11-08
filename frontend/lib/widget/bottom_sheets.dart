import 'package:flutter/material.dart';

class AppBottomSheets {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
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