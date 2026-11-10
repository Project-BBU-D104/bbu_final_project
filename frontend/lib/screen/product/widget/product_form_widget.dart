import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';
import 'package:get/get.dart';

/// Shared Add/Edit product form. Route adapters (AddProductWidget,
/// EditProductWidget) supply the title, submit label, and write handler.
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

  @override
  void initState() {
    super.initState();
    // A new form never shows the previous attempt's error.
    c.formError.value = '';
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
    if (c.isSaving.value) return;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => PopScope(
        // Block system back while a write is pending; the app-bar back
        // control is hidden for the same window.
        canPop: !c.isSaving.value,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: widget.title,
            showBack: !c.isSaving.value,
          ),

          // Persistent bottomSheet (not bottomNavigationBar) so the actions stay
          // above an onscreen keyboard.
          bottomSheet: SafeArea(
            child: Material(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      if (c.formError.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.formError.value,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      final uploadLoading =
                          Get.isRegistered<ImageUploadController>() &&
                          Get.find<ImageUploadController>().loading.value;
                      final busy = c.isSaving.value || uploadLoading;
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text('Cancel'.tr),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: busy ? null : _submit,
                              icon: c.isSaving.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(widget.submitLabel.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          body: SafeArea(
            child: Obx(() {
              // Rebuilding the form on saving-state changes keeps entered text:
              // the controllers own the values.
              final enabled = !c.isSaving.value;
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final info = _informationCard(enabled);
                          final pricing = _pricingCard(enabled);
                          final media = _imageDescriptionCard(enabled);

                          if (constraints.maxWidth >= 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: info),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      pricing,
                                      const SizedBox(height: 20),
                                      media,
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              info,
                              const SizedBox(height: 20),
                              pricing,
                              const SizedBox(height: 20),
                              media,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _informationCard(bool enabled) {
    return HomeSectionCard(
      title: 'Product Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: c.productNameController,
            focusNode: _nameNode,
            enabled: enabled,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '${'Product Name'.tr} *',
              hintText: 'Enter Product Name'.tr,
              border: const OutlineInputBorder(),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: c.productBarcodeController,
            focusNode: _barcodeNode,
            enabled: enabled,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '${'Barcode'.tr} *',
              hintText: 'Enter Barcode'.tr,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Scan Barcode'.tr,
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: enabled ? _scanBarcode : null,
              ),
            ),
            validator: _validateBarcode,
          ),
          const SizedBox(height: 16),
          _lookupDropdown(
            hint: 'Select Category',
            requiredLabel: 'Category'.tr,
            selectedGetter: () => c.selectedCategory.value,
            controller: c.categoryCtr,
            listGetter: (ctr) => ctr.categoryList,
            loadingGetter: (ctr) => ctr.isLoading.value,
            itemLabel: (item) => item['name'].toString(),
            errorText: 'Select a category.',
            focusNode: _categoryNode,
            enabled: enabled,
            onChanged: (value) => c.selectedCategory.value = value,
          ),
          const SizedBox(height: 16),
          _lookupDropdown(
            hint: 'Select Unit',
            requiredLabel: 'Unit'.tr,
            selectedGetter: () => c.selectedUnit.value,
            controller: c.unitCtr,
            listGetter: (ctr) => ctr.unitList,
            loadingGetter: (ctr) => ctr.isLoading.value,
            itemLabel: (item) => item['short_name'].toString(),
            errorText: 'Select a unit.',
            focusNode: _unitNode,
            enabled: enabled,
            onChanged: (value) => c.selectedUnit.value = value,
          ),
          const SizedBox(height: 16),
          _lookupDropdown(
            hint: 'Select Warehouse',
            requiredLabel: 'Warehouse'.tr,
            selectedGetter: () => c.selectedWarehouse.value,
            controller: c.warehouseCtr,
            listGetter: (ctr) => ctr.warehouseList,
            loadingGetter: (ctr) => ctr.isLoading.value,
            itemLabel: (item) => item['name'].toString(),
            errorText: null,
            focusNode: null,
            enabled: enabled,
            onChanged: (value) => c.selectedWarehouse.value = value,
          ),
        ],
      ),
    );
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
        decoration: InputDecoration(
          labelText: errorText == null ? requiredLabel : '$requiredLabel *',
          hintText: hint.tr,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
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

  Widget _pricingCard(bool enabled) {
    return HomeSectionCard(
      title: 'Pricing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lookupDropdown(
            hint: 'Select Currency',
            requiredLabel: 'Currency'.tr,
            selectedGetter: () => c.selectedCurrency.value,
            controller: c.currencyCtr,
            listGetter: (ctr) => ctr.currencyList,
            loadingGetter: (ctr) => ctr.isLoading.value,
            itemLabel: (item) => item['name'].toString(),
            errorText: 'Select a currency.',
            focusNode: _currencyNode,
            enabled: enabled,
            onChanged: (value) => c.selectedCurrency.value = value,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: c.productCostPriceController,
                  focusNode: _costNode,
                  enabled: enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${'Cost Price'.tr} *',
                    hintText: 'Enter Cost Price'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePrice,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: c.productSalePriceController,
                  focusNode: _saleNode,
                  enabled: enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '${'Sale Price'.tr} *',
                    hintText: 'Enter Sale Price'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePrice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageDescriptionCard(bool enabled) {
    final theme = Theme.of(context);
    return HomeSectionCard(
      title: 'Image and description',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (kIsWeb) ...[
            // The shared upload plugin has no browser support; show the
            // existing photo without an operative upload action.
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
              'Image upload is unavailable in the browser.'.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
            decoration: InputDecoration(
              labelText: 'Description'.tr,
              hintText: 'This is a sample description'.tr,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
