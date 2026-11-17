import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';
import 'package:get/get.dart';

class SearchWidget extends StatefulWidget {
  final String title;
  final bool showScan;
  final SearchController? searchController;
  final Future<String?> Function()? barcodeScanner;

  const SearchWidget({
    super.key,
    required this.title,
    this.showScan = false,
    this.searchController,
    this.barcodeScanner,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late SearchController ctr;
  Worker? _syncWorker;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    ctr =
        widget.searchController ??
        (Get.isRegistered<SearchController>()
            ? Get.find<SearchController>()
            : Get.put(SearchController()));
    _textController = TextEditingController(text: ctr.keyword.value);
    _textController.addListener(_onTextChanged);
    _bindSync();
  }

  void _bindSync() {
    _syncWorker = ever<String>(ctr.keyword, (value) {
      if (_textController.text == value) return;
      _textController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    });
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController == widget.searchController) return;
    _syncWorker?.dispose();
    ctr =
        widget.searchController ??
        (Get.isRegistered<SearchController>()
            ? Get.find<SearchController>()
            : Get.put(SearchController()));
    _textController.text = ctr.keyword.value;
    _bindSync();
  }

  void _onTextChanged() {
    ctr.keyword.value = _textController.text;
  }

  @override
  void dispose() {
    _syncWorker?.dispose();
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = widget.barcodeScanner != null
        ? await widget.barcodeScanner!()
        : await Get.to<String>(
            () => const TestProductScannerPage(returnImmediately: true),
          );

    if (!mounted || code == null || code.trim().isEmpty) return;

    final value = code.trim();

    _textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    ctr.keyword.value = value;
  }

  void _clear() {
    _textController.clear();
    ctr.keyword.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppTokens.controlHeight),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: widget.title.tr,
          labelText: widget.title.tr,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showScan)
                IconButton(
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan Barcode'.tr,
                ),
              Obx(() {
                return ctr.keyword.value.isEmpty
                    ? const SizedBox()
                    : IconButton(
                        onPressed: _clear,
                        tooltip: 'Clear search'.tr,
                        icon: const Icon(Icons.close),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
