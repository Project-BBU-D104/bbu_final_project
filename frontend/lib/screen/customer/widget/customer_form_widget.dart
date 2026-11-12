import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';

class CustomerFormWidget extends StatefulWidget {
  const CustomerFormWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.onSubmit,
  });

  final CustomerController controller;
  final String title;
  final Future<void> Function(BuildContext) onSubmit;

  @override
  State<CustomerFormWidget> createState() => _CustomerFormWidgetState();
}

class _CustomerFormWidgetState extends State<CustomerFormWidget> {
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _nameFocus = FocusNode();

  bool get _uploading =>
      Get.isRegistered<ImageUploadController>() &&
      Get.find<ImageUploadController>().loading.value;

  @override
  void initState() {
    super.initState();
    // Clear the shared upload preview once on entry, not on rebuild, so it
    // cannot display a previous customer's image.
    final upload = Get.isRegistered<ImageUploadController>()
        ? Get.find<ImageUploadController>()
        : Get.put(ImageUploadController());
    upload.clearImage();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSaving.value || _uploading) return;
    if (!widget.controller.formKey.currentState!.validate()) {
      if (_nameKey.currentContext != null) {
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
      final uploading =
          Get.isRegistered<ImageUploadController>() &&
          Get.find<ImageUploadController>().loading.value;
      final busy = c.isSaving.value || uploading;
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
                              Icons.people_outline,
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
                            'Customer details'.tr,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        key: _nameKey,
                        focusNode: _nameFocus,
                        controller: c.customerNameController,
                        enabled: !busy,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: decoration(
                          'Customer Name',
                          hint: 'Enter Customer Name',
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Customer name is required'.tr
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.customerPhoneNumberController,
                        enabled: !busy,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: decoration(
                          'Phone Number',
                          hint: 'Enter Phone Number',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.customerAddressController,
                        enabled: !busy,
                        minLines: 3,
                        maxLines: 6,
                        decoration: decoration(
                          'Address',
                          hint: 'Enter Address',
                        ),
                      ),
                      CheckboxListTile(
                        value: c.isActive.value,
                        onChanged: busy
                            ? null
                            : (v) => c.isActive.value = v ?? false,
                        title: Text('Active'.tr),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 8),
                      if (kIsWeb) ...[
                        // The shared upload plugin has no browser support;
                        // show the existing photo without an upload action.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppCachedImage(
                            url: c.customerPhotoController.text,
                            height: 120,
                            width: double.infinity,
                            fallbackIcon: Icons.image,
                            fallbackIconSize: 60,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image upload is unavailable in the browser.'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ] else
                        ImageUploadWidget(
                          bucket: 'customer',
                          folder: 'customers',
                          imageUrl: c.customerPhotoController.text,
                          onUploaded: (url) {
                            c.customerPhotoController.text = url;
                          },
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
