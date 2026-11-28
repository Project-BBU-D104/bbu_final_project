import 'package:flutter/material.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

/// A confirmation mark and receipt details, using the app's theme and spacing.
class AppSuccessReceipt extends StatelessWidget {
  const AppSuccessReceipt({super.key, required this.details});

  final List<({String label, String value})> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: reducedMotion ? 1 : AppTokens.successMarkInitialScale,
              end: 1,
            ),
            duration: reducedMotion
                ? Duration.zero
                : AppTokens.successMarkDuration,
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: ExcludeSemantics(
              child: Container(
                width: AppTokens.successMarkSize,
                height: AppTokens.successMarkSize,
                decoration: BoxDecoration(
                  color: dark
                      ? AppTokens.successMarkDarkBackground
                      : AppTokens.successMarkLightBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: AppTokens.successMarkIconSize,
                  color: dark
                      ? AppTokens.successMarkDarkForeground
                      : AppTokens.successMarkLightForeground,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Your payment has been recorded.'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppSectionCard(
          title: 'Receipt details',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final paired =
                  constraints.maxWidth >= AppTokens.bpMetaPair &&
                  MediaQuery.textScalerOf(context).scale(
                        theme.textTheme.bodyMedium?.fontSize ?? AppSpacing.lg,
                      ) <=
                      AppTokens.tableMaxScaledBodySize;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < details.length; i++) ...[
                    if (i > 0) const Divider(height: AppSpacing.xxl),
                    _ReceiptDetail(
                      label: details[i].label,
                      value: details[i].value,
                      paired: paired,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReceiptDetail extends StatelessWidget {
  const _ReceiptDetail({
    required this.label,
    required this.value,
    required this.paired,
  });

  final String label;
  final String value;
  final bool paired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final valueWidget = Text(
      value,
      textAlign: paired ? TextAlign.end : TextAlign.start,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
    if (paired) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: labelWidget),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: valueWidget),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget,
        const SizedBox(height: AppSpacing.xs),
        valueWidget,
      ],
    );
  }
}
