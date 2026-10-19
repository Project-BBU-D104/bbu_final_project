import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/payment/sale_with_payment/widget/payment_method_card_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class CurrentSaleWidget extends StatelessWidget {
  CurrentSaleWidget({super.key});

  final ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Current Sale"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: SelectCustomerCardWidget(),
              ),

              Obx(
                () => PaymentMethodCardWidget(
                  paymentTypes: ctr.paymentTypes.toList(),
                  selectedPaymentType: ctr.selectedPaymentType.value,
                  isLoading: ctr.isPaymentTypesLoading.value,
                  onChanged: (paymentType) {
                    if (paymentType != null) {
                      ctr.selectPaymentType(paymentType);
                    }
                  },
                ),
              ),

              Obx(() {
                if (ctr.selectedProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No products selected'),
                  );
                }
                return Column(
                  children: [
                    ...ctr.selectedProducts.map((product) {
                      final price =
                          double.tryParse(
                            product['sale_price']?.toString() ?? '',
                          ) ??
                          0;
                      final id = product['id'] as int;
                      final quantity = product['qty'] as int;
                      return CurrentSaleItemWidget(
                        imageUrl: product['photo']?.toString() ?? '',
                        productName: product['name']?.toString() ?? '',
                        unitPrice: price,
                        quantity: quantity,
                        subtotal: price * quantity,
                        currency: ctr.currency.value,
                        onIncrease: () => ctr.changeQuantity(id, 1),
                        onDecrease: () => ctr.changeQuantity(id, -1),
                      );
                    }),
                    SummaryOrderWidget(
                      subtotal: ctr.subtotal,
                      currency: ctr.currency.value,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  //do it
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Draft"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctr.isProcessingPayment.value
                      ? null
                      : ctr.onPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: ctr.isProcessingPayment.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Payment"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
