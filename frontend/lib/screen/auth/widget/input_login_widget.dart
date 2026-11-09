import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputLoginWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  const InputLoginWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onTogglePassword,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: false,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.onSurfaceVariant),
            prefixIcon: Icon(icon, size: 20, color: colors.onSurfaceVariant),
            suffixIcon: onTogglePassword == null
                ? null
                : IconButton(
                    tooltip:
                        obscureText ? 'Show password'.tr : 'Hide password'.tr,
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: colors.primary, width: 1.6),
            ),
            errorBorder: border.copyWith(
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: BorderSide(color: colors.error, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}