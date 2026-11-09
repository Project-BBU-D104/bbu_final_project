import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/widgets/supplier_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class SupplierScreen extends StatelessWidget {
  SupplierScreen({super.key});
  final controller = Get.find<SupplierController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Suppliers', useTheme: true),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < 600 ? 16.0 : 32.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Suppliers'.tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              FilledButton.icon(
                                onPressed: () =>
                                    controller.addSupplier(context),
                                icon: const Icon(Icons.add),
                                label: Text('Add Supplier'.tr),
                              ),
                              IconButton(
                                tooltip: 'Refresh'.tr,
                                onPressed: controller.onRefresh,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Manage supplier contacts and locations.'.tr),
                          const SizedBox(height: 16),
                          const SearchWidget(title: 'Search Suppliers'),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      child: Obx(() {
                        final loading = controller.isLoading.value;
                        final error = controller.loadError.value;
                        final items = controller.searchSuppliers.toList();
                        if (loading && controller.suppliers.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (loading) const LinearProgressIndicator(),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Wrap(
                                  spacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(error),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : controller.onRefresh,
                                      child: Text('Retry'.tr),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: items.isEmpty
                                  ? SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Text(
                                          error.isNotEmpty
                                              ? ''
                                              : (controller.suppliers.isEmpty
                                                        ? 'No suppliers yet'
                                                        : 'No matching suppliers')
                                                    .tr,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, content) {
                                        final table =
                                            content.maxWidth >= 1000 &&
                                            MediaQuery.textScalerOf(
                                                  context,
                                                ).scale(16) <=
                                                20.8;
                                        return RefreshIndicator(
                                          onRefresh: controller.onRefresh,
                                          child: table
                                              ? SingleChildScrollView(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  child: SupplierTableWidget(
                                                    items: items,
                                                  ),
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemCount: items.length,
                                                  itemBuilder: (_, i) =>
                                                      SupplierCardWidget(
                                                        item: items[i],
                                                      ),
                                                ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
