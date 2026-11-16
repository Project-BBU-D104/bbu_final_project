import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';

class WarehouseStockFormWidget extends StatefulWidget {
  const WarehouseStockFormWidget({super.key, this.warehouseStockId});
  final int? warehouseStockId;
  @override
  State<WarehouseStockFormWidget> createState() =>
      _WarehouseStockFormWidgetState();
}

class _WarehouseStockFormWidgetState extends State<WarehouseStockFormWidget> {
  final c = Get.find<WarehouseStockController>();
  final _form = GlobalKey<FormState>();
  final _warehouseKey = GlobalKey();
  final _productKeys = <TextEditingController, GlobalKey>{};
  final _qtyKeys = <TextEditingController, GlobalKey<FormFieldState<String>>>{};
  final _pickerErrors = <GlobalKey, String?>{};
  final _focusNodes = <GlobalKey, FocusNode>{};
  FocusNode _focus(GlobalKey key, {String? label}) =>
      _focusNodes.putIfAbsent(key, () => FocusNode(debugLabel: label));
  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _warehouses = [], _products = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final warehouse = Get.find<WarehouseController>();
      final product = Get.find<ProductController>();
      // Keep these fresh form options local. The list controller owns its
      // records, active search, and request generations.
      final results = await Future.wait([
        warehouse.service.getWarehouses(),
        product.service.getProducts(),
      ]);
      if (results.any((r) => r is! List)) throw const FormatException();
      final warehouses = List<Map<String, dynamic>>.from(results[0]);
      final products = List<Map<String, dynamic>>.from(results[1]);
      if (!mounted) return;
      setState(() {
        _warehouses = warehouses;
        _products = products;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to load stock options. Please try again.'.tr,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _name(Map<String, dynamic> r) => '${r['name'] ?? r['id'] ?? ''}';
  Widget _picker({
    required String label,
    required RxnString selection,
    required List<Map<String, dynamic>> items,
    required GlobalKey fieldKey,
    required String missing,
    bool product = false,
  }) {
    return Focus(
      focusNode: _focus(fieldKey, label: label),
      child: DropdownSearch<Map<String, dynamic>>(
        key: fieldKey,
        enabled: !c.isSaving.value && !_loading && _error.isEmpty,
        selectedItem: items.firstWhereOrNull(
          (r) => '${r['id']}' == selection.value,
        ),
        items: (filter, _) => items
            .where((r) => _name(r).toLowerCase().contains(filter.toLowerCase()))
            .toList(),
        itemAsString: _name,
        compareFn: (a, b) => a['id'] == b['id'],
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(labelText: label.tr),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(labelText: 'Search'.tr),
          ),
        ),
        validator: (value) {
          String? error;
          if (value == null ||
              !items.any((r) => '${r['id']}' == selection.value)) {
            error = missing.tr;
          } else if (product &&
              c.productRows
                      .where(
                        (r) =>
                            (r['product'] as RxnString).value ==
                            selection.value,
                      )
                      .length >
                  1) {
            error = 'Select each product only once'.tr;
          }
          _pickerErrors[fieldKey] = error;
          return error;
        },
        onChanged: (value) =>
            selection.value = value == null ? null : '${value['id']}',
      ),
    );
  }

  void _save() {
    if (_loading || _error.isNotEmpty || c.isSaving.value) return;
    final valid = _form.currentState!.validate();
    final draftValid = c.validateDraft();
    if (!valid || !draftValid) {
      final keys = <GlobalKey>[
        _warehouseKey,
        for (final row in c.productRows) ...[
          _productKeys[row['qty']]!,
          _qtyKeys[row['qty']]!,
        ],
      ];
      for (final key in keys) {
        final state = key.currentState;
        final invalid =
            _pickerErrors[key] != null ||
            (state is FormFieldState && state.hasError);
        if (invalid && key.currentContext != null) {
          Scrollable.ensureVisible(key.currentContext!);
          _focus(key).requestFocus();
          break;
        }
      }
      return;
    }
    if (widget.warehouseStockId == null) {
      c.onSaveWarehouseStock(context);
    } else {
      c.onUpdateWarehouseStock(widget.warehouseStockId!, context);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = c.isSaving.value;
    final rows = c.productRows.toList();
    return PopScope(
      canPop: !saving,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (widget.warehouseStockId == null
                                ? 'Add Warehouse Stock'
                                : 'Edit Warehouse Stock')
                            .tr,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close'.tr,
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_loading) const LinearProgressIndicator(),
                        if (_error.isNotEmpty) ...[
                          Text(_error),
                          TextButton(
                            onPressed: saving ? null : _load,
                            child: Text('Retry'.tr),
                          ),
                        ],
                        AppFormSection(
                          title: 'Warehouse',
                          children: [
                            _picker(
                              label: 'Warehouse',
                              selection: c.selectedWarehouse,
                              items: _warehouses,
                              fieldKey: _warehouseKey,
                              missing: 'Please select a warehouse',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppFormSection(
                          title: 'Products and quantities',
                          children: [
                            for (final row in rows)
                              Padding(
                                key: ObjectKey(row['qty']),
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.lg,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final qty =
                                        row['qty'] as TextEditingController;
                                    final product = _picker(
                                      label: 'Product',
                                      selection: row['product'] as RxnString,
                                      items: _products,
                                      fieldKey: _productKeys.putIfAbsent(
                                        qty,
                                        () => GlobalKey(),
                                      ),
                                      missing: 'Select a product',
                                      product: true,
                                    );
                                    final quantity = AppFormField(
                                      label: 'Quantity',
                                      fieldKey: _qtyKeys.putIfAbsent(
                                        qty,
                                        () =>
                                            GlobalKey<FormFieldState<String>>(),
                                      ),
                                      focusNode: _focus(_qtyKeys[qty]!),
                                      controller: qty,
                                      keyboardType: TextInputType.number,
                                      enabled: !saving,
                                      validator: c.quantityError,
                                      wrapErrors: true,
                                    );
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (constraints.maxWidth >=
                                                AppTokens.bpFormPair &&
                                            MediaQuery.textScalerOf(
                                                  context,
                                                ).scale(16) <=
                                                AppTokens
                                                    .tableMaxScaledBodySize)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: product),
                                              const SizedBox(
                                                width: AppSpacing.lg,
                                              ),
                                              Expanded(child: quantity),
                                            ],
                                          )
                                        else ...[
                                          product,
                                          const SizedBox(height: AppSpacing.lg),
                                          quantity,
                                        ],
                                        if (widget.warehouseStockId == null &&
                                            rows.length > 1)
                                          Align(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            child: IconButton(
                                              tooltip: 'Remove product'.tr,
                                              onPressed: saving
                                                  ? null
                                                  : () => c.removeProductRow(
                                                      rows.indexOf(row),
                                                    ),
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            if (widget.warehouseStockId == null)
                              TextButton.icon(
                                key: const Key('stock-add-row'),
                                onPressed: saving ? null : c.addProductRow,
                                icon: const Icon(Icons.add),
                                label: Text('Add product'.tr),
                              ),
                          ],
                        ),
                        if (c.formError.value.isNotEmpty)
                          Semantics(
                            liveRegion: true,
                            child: Text(c.formError.value),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppFormActions(
                  onCancel: saving ? null : () => Navigator.of(context).pop(),
                  onSave: _loading || _error.isNotEmpty ? null : _save,
                  saving: saving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}
