import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:get/get.dart';

class CategoryFormWidget extends StatefulWidget {
  const CategoryFormWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.onSubmit,
  });

  final CategoryController controller;
  final String title;
  final Future<void> Function(BuildContext) onSubmit;

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSaving.value) return;
    if (!widget.controller.formKey.currentState!.validate()) {
      if (_nameKey.currentState?.hasError == true &&
          _nameKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _nameKey.currentContext!,
          duration: const Duration(milliseconds: 150),
        );
        if (mounted) FocusScope.of(context).requestFocus(_nameFocus);
      }
      return;
    }
    FocusScope.of(context).unfocus();
    await widget.onSubmit(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    InputDecoration decoration(String label, {String? hint}) => InputDecoration(
      labelText: label.tr,
      hintText: hint?.tr,
      filled: true,
      fillColor: Color.alphaBlend(
        colors.onSurface.withValues(alpha: 0.025),
        theme.cardColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
    return Obx(() {
      final busy = c.isSaving.value;
      final error = c.formError.value;
      return PopScope(
        canPop: !busy,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.category_outlined,
                              color: colors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title.tr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close'.tr,
                            onPressed: busy
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          height: 1,
                          color: colors.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Semantics(
                          header: true,
                          child: Text(
                            'Category details'.tr,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        key: _nameKey,
                        focusNode: _nameFocus,
                        controller: c.nameController,
                        enabled: !busy,
                        textInputAction: TextInputAction.next,
                        decoration: decoration(
                          'Category Name',
                          hint: 'Enter Category Name',
                        ),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty
                            ? 'Category name is required'.tr
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.descriptionController,
                        enabled: !busy,
                        minLines: 3,
                        maxLines: 6,
                        decoration: decoration(
                          'Description',
                          hint: 'Enter Description',
                        ),
                      ),
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          height: 1,
                          color: colors.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(100, 48),
                              side: BorderSide(
                                color: colors.onSurface.withValues(alpha: 0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Cancel'.tr),
                          ),
                          FilledButton(
                            onPressed: busy ? null : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(112, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: busy
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Saving...'.tr),
                                    ],
                                  )
                                : Text('Save'.tr),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}