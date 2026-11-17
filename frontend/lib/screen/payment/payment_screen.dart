import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/payment/widget/payment_card_list_widget.dart';
import 'package:frontend/screen/payment/widget/payment_table_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_search_field.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});
  final ctr = Get.isRegistered<PaymentController>()
      ? Get.find<PaymentController>()
      : Get.put(PaymentController());

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppPage(
      child: LayoutBuilder(
        builder: (context, bounds) => RefreshIndicator(
          onRefresh: ctr.onRefresh,
          child: Obx(() {
            final rows = ctr.filteredPaymentList;
            final loading = ctr.isLoading.value;
            final error = ctr.loadError.value;
            final initialPending =
                ctr.paymentList.isEmpty && (loading || error.isNotEmpty);
            final largeText =
                MediaQuery.textScalerOf(context).scale(
                  Theme.of(context).textTheme.bodyMedium?.fontSize ??
                      AppSpacing.lg,
                ) >
                AppTokens.tableMaxScaledBodySize;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPageHeader(
                        title: 'Payment',
                        leading: IconButton(
                          tooltip: 'Back'.tr,
                          onPressed: () => Navigator.of(context).canPop()
                              ? Get.back()
                              : Get.offNamed(AppRoutes.home),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        actions: Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            Obx(
                              () => FilledButton(
                                onPressed: ctr.isOpeningForm.value
                                    ? null
                                    : () => ctr.addPayment(context),
                                child: Text('Add Payment'.tr),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Refresh'.tr,
                              onPressed: ctr.onRefresh,
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppSearchField(
                        title: 'Search Payment',
                        searchController: ctr.searchCtr,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (error.isNotEmpty)
                        Semantics(
                          liveRegion: true,
                          child: Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(error.tr),
                              TextButton(
                                onPressed: ctr.onRefresh,
                                child: Text('Retry'.tr),
                              ),
                            ],
                          ),
                        ),
                      if (loading) const LinearProgressIndicator(),
                    ],
                  ),
                ),
                if (rows.isEmpty && !initialPending)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AppEmptyState(
                          message: ctr.paymentList.isEmpty
                              ? 'No payments found'
                              : 'No matching payments',
                        ),
                        if (ctr.searchCtr.keyword.value.isNotEmpty)
                          TextButton(
                            onPressed: ctr.searchCtr.clear,
                            child: Text('Clear search'.tr),
                          ),
                      ],
                    ),
                  )
                else if (rows.isNotEmpty &&
                    bounds.maxWidth >= AppTokens.bpTable &&
                    !largeText)
                  SliverToBoxAdapter(
                    child: PaymentTableWidget(
                      payments: rows,
                      onEdit: (payment) => ctr.editPayment(context, payment),
                      onDelete: (payment) =>
                          ctr.onDeletePayment(context, payment['id']),
                    ),
                  )
                else if (rows.isNotEmpty)
                  SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) => PaymentCardListWidget(
                      payment: rows[index],
                      onEdit: () => ctr.editPayment(context, rows[index]),
                      onDelete: () =>
                          ctr.onDeletePayment(context, rows[index]['id']),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    ),
  );
}
