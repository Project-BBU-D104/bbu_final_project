import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/payment/sale_with_payment/widget/payment_method_card_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class CurrentSaleWidget extends StatelessWidget {
  CurrentSaleWidget({super.key});
  final SaleController? _controller = Get.isRegistered<SaleController>()
      ? Get.find<SaleController>()
      : null;
  SaleController get ctr => _controller!;
  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      void backToProducts() {
        if (Navigator.of(context).canPop()) {
          Get.back();
        } else {
          Get.offNamed(AppRoutes.sale);
        }
      }

      return Scaffold(
        appBar: DesktopAppShell.isVisible(context)
            ? null
            : CustomAppBar(title: 'Current Sale', onBack: backToProducts),
        body: AppPage(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppPageHeader(title: 'Current Sale'),
                const SizedBox(height: AppSpacing.lg),
                const AppEmptyState(
                  message: 'No products selected',
                  icon: Icons.shopping_cart_outlined,
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: backToProducts,
                  child: Text('Back to products'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _cart(context);
  }

  Widget _cart(BuildContext context) => Obx(
    () => PopScope(
      canPop: !ctr.checkoutBusy,
      child: Scaffold(
        appBar: DesktopAppShell.isVisible(context)
            ? null
            : CustomAppBar(
                title: 'Current Sale',
                onBack: () {
                  if (!ctr.checkoutBusy) Get.back();
                },
              ),
        body: AppPage(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppPageHeader(title: 'Current Sale'),
                const SizedBox(height: AppSpacing.lg),
                if (ctr.selectedProducts.isEmpty)
                  const AppEmptyState(
                    message: 'No products selected',
                    icon: Icons.shopping_cart_outlined,
                  )
                else
                  LayoutBuilder(
                    builder: (context, bounds) => Obx(() {
                      final alignment = DesktopAppShell.isVisible(context)
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.stretch;
                      final items = Column(
                        crossAxisAlignment: alignment,
                        children: ctr.selectedProducts.map((p) {
                          final price =
                              double.tryParse(
                                p['sale_price']?.toString() ?? '',
                              ) ??
                              0;
                          return CurrentSaleItemWidget(
                            enabled: !ctr.cartLocked,
                            warehouseName: p['qty'] > p['available_qty']
                                ? "${p['warehouse_name']} · ${'Available: @qty'.trParams({'qty': "${p['available_qty']}"})}"
                                : p['warehouse_name'],
                            productName: p['name']?.toString() ?? '',
                            imageUrl: p['photo']?.toString() ?? '',
                            quantity: p['qty'],
                            unitPrice: price,
                            subtotal: price * p['qty'],
                            currency: ctr.currency.value,
                            onIncrease: p['qty'] >= p['available_qty']
                                ? null
                                : () => ctr.changeQuantity(
                                    p['id'],
                                    p['warehouse_id'],
                                    1,
                                  ),
                            onDecrease: () => ctr.changeQuantity(
                              p['id'],
                              p['warehouse_id'],
                              -1,
                            ),
                          );
                        }).toList(),
                      );
                      final details = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IgnorePointer(
                            ignoring: ctr.cartLocked,
                            child: SelectCustomerCardWidget(
                              enabled: !ctr.cartLocked,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PaymentMethodCardWidget(
                            loadError: ctr.paymentTypesLoadError.value,
                            onRetry: ctr.loadPaymentTypes,
                            enabled: !ctr.cartLocked,
                            paymentTypes: ctr.paymentTypes.toList(),
                            selectedPaymentType: ctr.selectedPaymentType.value,
                            isLoading:
                                ctr.isPaymentTypesLoading.value ||
                                ctr.checkoutBusy,
                            onChanged: (value) {
                              if (value != null) ctr.selectPaymentType(value);
                            },
                          ),
                          if (ctr.currencyLoadError.value.isNotEmpty)
                            Text(ctr.currencyLoadError.value),
                          if (ctr.currencyLoadError.value.isNotEmpty)
                            TextButton(
                              onPressed: ctr.checkoutBusy
                                  ? null
                                  : ctr.loadCurrency,
                              child: Text('Retry'.tr),
                            ),
                          const SizedBox(height: AppSpacing.lg),
                          SummaryOrderWidget(
                            subtotal: ctr.subtotal,
                            currency: ctr.currency.value,
                          ),
                        ],
                      );
                      if (bounds.maxWidth >= AppTokens.bpTwoColumn &&
                          MediaQuery.textScalerOf(context).scale(
                                Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.fontSize ??
                                    AppSpacing.lg,
                              ) <=
                              AppTokens.tableMaxScaledBodySize) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: items),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: details),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: alignment,
                        children: [
                          items,
                          const SizedBox(height: AppSpacing.lg),
                          details,
                        ],
                      );
                    }),
                  ),
                if (ctr.checkoutError.value.isNotEmpty)
                  Text(ctr.checkoutError.value),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    OutlinedButton(
                      onPressed: ctr.checkoutBusy ? null : () => Get.back(),
                      child: Text('Back to products'.tr),
                    ),
                    if (ctr.checkoutConflict.value &&
                        ctr.hasPendingCheckout) ...[
                      OutlinedButton(
                        onPressed: () => Get.toNamed(AppRoutes.saleList),
                        child: Text('Sales history'.tr),
                      ),
                      TextButton(
                        onPressed: ctr.checkoutBusy
                            ? null
                            : ctr.dismissConflict,
                        child: Text('Dismiss conflicting checkout'.tr),
                      ),
                    ] else
                      FilledButton(
                        onPressed:
                            (ctr.hasPendingCheckout
                                ? !ctr.checkoutBusy
                                : ctr.canCheckout)
                            ? ctr.onPayment
                            : null,
                        child: Text(
                          (ctr.checkoutBusy
                                  ? 'Processing...'
                                  : ctr.hasPendingCheckout
                                  ? 'Retry checkout'
                                  : 'Payment')
                              .tr,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
