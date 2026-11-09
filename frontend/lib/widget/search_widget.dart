import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';
import 'package:get/get.dart';

class SearchWidget extends StatefulWidget {
  final String title;
  final bool showScan;

  const SearchWidget({super.key, required this.title, this.showScan = false});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final SearchController ctr;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    ctr = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _textController = TextEditingController(text: ctr.keyword.value);
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    ctr.keyword.value = _textController.text;
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = await Get.to<String>(
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
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: widget.title.tr,
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
                        tooltip: 'Clear search'.tr,
                      );
              }),
            ],
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
