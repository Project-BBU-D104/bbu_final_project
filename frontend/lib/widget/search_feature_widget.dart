import 'package:flutter/material.dart';
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:get/get.dart';

class SearchFeatureWidget extends StatelessWidget {
  const SearchFeatureWidget({
    super.key,
    required this.title,
    required this.ctr,
  });
  final String title;
  final SearchFeatureController ctr;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: ctr.textController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: title.tr,
        filled: true,
        fillColor: colors.surface,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(
          () => ctr.keyword.value.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search'.tr,
                  onPressed: ctr.clear,
                  icon: const Icon(Icons.close),
                ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }
}
