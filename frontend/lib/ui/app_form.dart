import 'package:flutter/material.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

/// A titled block of form fields.
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// Translated with `.tr`.
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Semantics(
            header: true,
            child: Text(
              title.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// A text field that takes its look from the theme's input decoration.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.fieldKey,
    this.focusNode,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.hint,
    this.suffix,
    this.minLines,
    this.maxLines,
    this.obscureText = false,
    this.trimValue = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.onFieldSubmitted,
    this.wrapErrors = false,
  });

  final String label;

  /// The key of the inner form field, for scroll-to-error.
  final Key? fieldKey;

  final FocusNode? focusNode;
  final TextEditingController? controller;

  /// Receives a trimmed value unless [trimValue] is false (for passwords).
  final String? Function(String?)? validator;

  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hint;
  final Widget? suffix;
  final int? minLines;
  final int? maxLines;
  final bool obscureText;
  final bool trimValue;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  /// Allow translated validation messages to occupy as many lines as needed.
  final bool wrapErrors;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: fieldKey,
    focusNode: focusNode,
    controller: controller,
    enabled: enabled,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    minLines: minLines,
    maxLines: obscureText ? 1 : maxLines,
    obscureText: obscureText,
    autocorrect: autocorrect,
    enableSuggestions: enableSuggestions,
    autofillHints: autofillHints,
    onFieldSubmitted: onFieldSubmitted,
    errorBuilder: wrapErrors
        ? (context, error) =>
              Text(error, softWrap: true, overflow: TextOverflow.visible)
        : null,
    decoration: InputDecoration(
      labelText: label.tr,
      hintText: hint?.tr,
      suffixIcon: suffix,
    ),
    validator: validator == null
        ? null
        : (value) => validator!(trimValue ? (value ?? '').trim() : value ?? ''),
  );
}

/// The cancel and save pair at the end of a form.
class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.saving = false,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
  });

  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool saving;

  /// Translated with `.tr`.
  final String saveLabel;

  /// Translated with `.tr`.
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusControl),
    );
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        OutlinedButton(
          onPressed: saving ? null : onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, AppTokens.controlHeight),
            shape: shape,
          ),
          child: Text(cancelLabel.tr),
        ),
        FilledButton(
          onPressed: saving ? null : onSave,
          style: FilledButton.styleFrom(
            minimumSize: const Size(112, AppTokens.controlHeight),
            shape: shape,
          ),
          child: saving
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Saving...'.tr),
                  ],
                )
              : Text(saveLabel.tr),
        ),
      ],
    );
  }
}

/// Presents a form as a dialog on wide pages and a bottom sheet on narrow
/// ones. Dismissal is blocked so a half typed record is never lost.
class AppFormShell {
  const AppFormShell._();

  static Future<void> show(BuildContext context, Widget child) async {
    if (MediaQuery.sizeOf(context).width >= AppTokens.bpDesktop) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          constraints: const BoxConstraints(maxWidth: 720),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSheet),
          ),
          child: child,
        ),
      );
    } else {
      await AppBottomSheets.show(
        context,
        child: child,
        isDismissible: false,
        enableDrag: false,
        constraints: const BoxConstraints(maxWidth: 760),
      );
    }
  }
}
