import 'package:flutter/material.dart';

/// Secondary information shown on a filled primary button.
class AppButtonSupportingText extends StatelessWidget {
  const AppButtonSupportingText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
