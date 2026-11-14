import 'package:flutter/material.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

/// Shared presentation for account forms; fields own their validation.
class ProfileFormLayout extends StatelessWidget {
  const ProfileFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formKey,
    required this.saving,
    required this.child,
    required this.onSubmit,
    this.saveLabel = 'Save',
  });
  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final bool saving;
  final Widget child;
  final VoidCallback onSubmit;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !saving,
      child: Material(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.xxl,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(title.tr, style: textTheme.titleLarge),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        tooltip: 'Close'.tr,
                        onPressed: saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle.tr, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xxl),
                  child,
                  const SizedBox(height: AppSpacing.xxl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  AppFormActions(
                    saving: saving,
                    saveLabel: saveLabel,
                    onCancel: saving ? null : () => Navigator.of(context).pop(),
                    onSave: saving ? null : onSubmit,
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
