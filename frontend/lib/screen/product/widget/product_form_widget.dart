import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';
import 'package:get/get.dart';

/// Shared Add/Edit product form, presented by the controller in a desktop
/// dialog or a mobile bottom sheet. Adapters supply the title, submit label,
/// and write handler.
class ProductFormWidget extends StatefulWidget {
  const ProductFormWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
  });

  final ProductController controller;
  final String title;
  final String submitLabel;
  final Future<void> Function(BuildContext) onSubmit;

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameNode = FocusNode();
  final _barcodeNode = FocusNode();
  final _categoryNode = FocusNode();
  final _unitNode = FocusNode();
  final _currencyNode = FocusNode();
  final _costNode = FocusNode();
  final _saleNode = FocusNode();

  ProductController get c => widget.controller;

  bool get _uploading =>
      Get.isRegistered<ImageUploadController>() &&
      Get.find<ImageUploadController>().loading.value;

  @override
  void initState() {
    super.initState();
    // Clear the shared upload preview once on entry, not on rebuild, so it
    // cannot display a previous product's image.
    final upload = Get.isRegistered<ImageUploadController>()
        ? Get.find<ImageUploadController>()
        : Get.put(ImageUploadController());
    upload.clearImage();
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _barcodeNode.dispose();
    _categoryNode.dispose();
    _unitNode.dispose();
    _currencyNode.dispose();
    _costNode.dispose();
    _saleNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter a product name.'.tr : null;

  String? _validateBarcode(String? value) =>
      (value ?? '').trim().isEmpty ? 'Enter a barcode.'.tr : null;

  String? _validatePrice(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return 'Enter a valid price of zero or more.'.tr;
    }
    return null;
  }

  bool _idAvailable(List<Map<String, dynamic>> items, String? id) =>
      id != null && items.any((item) => item['id'].toString() == id);

  void _submit() {
    if (c.isSaving.value || _uploading) return;
    c.formError.value = '';

    // Show inline errors, then focus the first invalid field in display
    // order. Lookup selections are validated against the loaded choices so a
    // stale or still-loading id can never reach the service.
    final formOk = _formKey.currentState?.validate() ?? false;
    final firstInvalid = <(FocusNode, bool)>[
      (_nameNode, _validateName(c.productNameController.text) == null),
      (_barcodeNode, _validateBarcode(c.productBarcodeController.text) == null),
      (
        _categoryNode,
        _idAvailable(c.categoryCtr.categoryList, c.selectedCategory.value),
      ),
      (_unitNode, _idAvailable(c.unitCtr.unitList, c.selectedUnit.value)),
      (
        _currencyNode,
        _idAvailable(c.currencyCtr.currencyList, c.selectedCurrency.value),
      ),
      (_costNode, _validatePrice(c.productCostPriceController.text) == null),
      (_saleNode, _validatePrice(c.productSalePriceController.text) == null),
    ].where((entry) => !entry.$2).map((entry) => entry.$1);

    if (firstInvalid.isNotEmpty) {
      firstInvalid.first.requestFocus();
      return;
    }
    if (!formOk) return;

    widget.onSubmit(context);
  }

  Future<void> _scanBarcode() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const TestProductScannerPage(returnImmediately: true),
      ),
    );

    if (!mounted) return;
    if (code == null || code.trim().isEmpty) return;

    final value = code.trim();
    c.productBarcodeController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    Widget? suffix,
    String? hint,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InputDecoration(
      labelText: label.tr,
      hintText: hint?.tr,
      suffixIcon: suffix,
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        header: true,
        child: Text(
          text.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    return Obx(() {
      final busy = c.isSaving.value || _uploading;
      final error = c.formError.value;
      final enabled = !busy;
      return PopScope(
        // Block system back while a write or upload is pending; the close
        // control is disabled for the same window.
        canPop: !busy,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            // Lift the pinned footer above an onscreen keyboard.
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: theme.brightness == Brightness.light
                                  ? colors.primaryContainer
                                  : colors.primary,
                              size: 22,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Divider(
                        height: 1,
                        color: colors.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              heading('Product Information'),
                              TextFormField(
                                controller: c.productNameController,
                                focusNode: _nameNode,
                                enabled: enabled,
                                textInputAction: TextInputAction.next,
                                decoration: _decoration(
                                  context,
                                  'Product Name',
                                  hint: 'Enter Product Name',
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: c.productBarcodeController,
                                focusNode: _barcodeNode,
                                enabled: enabled,
                                textInputAction: TextInputAction.next,
                                decoration: _decoration(
                                  context,
                                  'Barcode',
                                  hint: 'Enter Barcode',
                                  suffix: IconButton(
                                    tooltip: 'Scan Barcode'.tr,
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 20,
                                    ),
                                    onPressed: enabled ? _scanBarcode : null,
                                  ),
                                ),
                                validator: _validateBarcode,
                              ),
                              const SizedBox(height: 20),
                              _lookupDropdown(
                                hint: 'Select Category',
                                requiredLabel: 'Category',
                                selectedGetter: () => c.selectedCategory.value,
                                controller: c.categoryCtr,
                                listGetter: (ctr) => ctr.categoryList,
                                loadingGetter: (ctr) => ctr.isLoading.value,
                                itemLabel: (item) => item['name'].toString(),
                                errorText: 'Select a category.',
                                focusNode: _categoryNode,
                                enabled: enabled,
                                onChanged: (value) =>
                                    c.selectedCategory.value = value,
                              ),
                              const SizedBox(height: 20),
                              _lookupDropdown(
                                hint: 'Select Unit',
                                requiredLabel: 'Unit',
                                selectedGetter: () => c.selectedUnit.value,
                                controller: c.unitCtr,
                                listGetter: (ctr) => ctr.unitList,
                                loadingGetter: (ctr) => ctr.isLoading.value,
                                itemLabel: (item) =>
                                    item['short_name'].toString(),
                                errorText: 'Select a unit.',
                                focusNode: _unitNode,
                                enabled: enabled,
                                onChanged: (value) =>
                                    c.selectedUnit.value = value,
                              ),
                              const SizedBox(height: 20),
                              _lookupDropdown(
                                hint: 'Select Warehouse',
                                requiredLabel: 'Warehouse',
                                selectedGetter: () => c.selectedWarehouse.value,
                                controller: c.warehouseCtr,
                                listGetter: (ctr) => ctr.warehouseList,
                                loadingGetter: (ctr) => ctr.isLoading.value,
                                itemLabel: (item) => item['name'].toString(),
                                errorText: null,
                                focusNode: null,
                                enabled: enabled,
                                onChanged: (value) =>
                                    c.selectedWarehouse.value = value,
                              ),
                              const SizedBox(height: 28),
                              heading('Pricing'),
                              _lookupDropdown(
                                hint: 'Select Currency',
                                requiredLabel: 'Currency',
                                selectedGetter: () => c.selectedCurrency.value,
                                controller: c.currencyCtr,
                                listGetter: (ctr) => ctr.currencyList,
                                loadingGetter: (ctr) => ctr.isLoading.value,
                                itemLabel: (item) => item['name'].toString(),
                                errorText: 'Select a currency.',
                                focusNode: _currencyNode,
                                enabled: enabled,
                                onChanged: (value) =>
                                    c.selectedCurrency.value = value,
                              ),
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) => Wrap(
                                  spacing: 16,
                                  runSpacing: 20,
                                  children: [
                                    for (final item in [
                                      TextFormField(
                                        controller:
                                            c.productCostPriceController,
                                        focusNode: _costNode,
                                        enabled: enabled,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        textInputAction: TextInputAction.next,
                                        decoration: _decoration(
                                          context,
                                          'Cost Price',
                                          hint: 'Enter Cost Price',
                                        ),
                                        validator: _validatePrice,
                                      ),
                                      TextFormField(
                                        controller:
                                            c.productSalePriceController,
                                        focusNode: _saleNode,
                                        enabled: enabled,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: _decoration(
                                          context,
                                          'Sale Price',
                                          hint: 'Enter Sale Price',
                                        ),
                                        validator: _validatePrice,
                                      ),
                                    ])
                                      SizedBox(
                                        width: constraints.maxWidth >= 560
                                            ? (constraints.maxWidth - 16) / 2
                                            : constraints.maxWidth,
                                        child: item,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              heading('Image and description'),
                              if (kIsWeb) ...[
                                // The shared upload plugin has no browser
                                // support; show the existing photo without an
                                // operative upload action.
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppCachedImage(
                                    url: c.productPhotoController.text,
                                    height: 120,
                                    width: double.infinity,
                                    fallbackIcon: Icons.image,
                                    fallbackIconSize: 60,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image upload is unavailable in the browser.'
                                      .tr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ] else
                                ImageUploadWidget(
                                  bucket: 'product',
                                  folder: 'products',
                                  imageUrl: c.productPhotoController.text,
                                  onUploaded: (url) {
                                    c.productPhotoController.text = url;
                                  },
                                ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: c.productDescriptionController,
                                enabled: enabled,
                                minLines: 3,
                                maxLines: 8,
                                decoration: _decoration(
                                  context,
                                  'Description',
                                  hint: 'This is a sample description',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Divider(
                        height: 1,
                        color: colors.onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                                    color: colors.onSurface.withValues(
                                      alpha: 0.12,
                                    ),
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
                                    : Text(widget.submitLabel.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Dropdown bound to a lookup controller's Rx list. The displayed value is
  /// guarded against absent options while the controller's selection is kept
  /// until the user corrects it; submission is blocked by [errorText].
  Widget _lookupDropdown<T extends GetxController>({
    required String hint,
    required String requiredLabel,
    required String? Function() selectedGetter,
    required T controller,
    required List<Map<String, dynamic>> Function(T) listGetter,
    required bool Function(T) loadingGetter,
    required String Function(Map<String, dynamic>) itemLabel,
    required String? errorText,
    required FocusNode? focusNode,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      if (loadingGetter(controller)) {
        return const Center(child: CircularProgressIndicator());
      }
      final items = listGetter(controller);
      final selected = selectedGetter();
      final available =
          selected != null &&
          items.any((item) => item['id'].toString() == selected);

      return DropdownButtonFormField<String>(
        initialValue: available ? selected : null,
        isExpanded: true,
        focusNode: focusNode,
        decoration: _decoration(context, requiredLabel, hint: hint),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(itemLabel(item)),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
        validator: errorText == null
            ? null
            : (value) => value == null ? errorText.tr : null,
      );
    });
  }
}
