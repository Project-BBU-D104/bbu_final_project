import 'package:flutter/material.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:get/get.dart';

class PaymentCardListWidget extends StatelessWidget {
  const PaymentCardListWidget({
    super.key,
    required this.payment,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> payment;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final sale = saleMap(payment['sale']);
    return AppListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(saleText(sale['invoice_no'])),
          Text(saleText(saleMap(sale['customer'])['name'])),
          Text(formatSaleAmount(payment['amount'])),
          Text(saleText(payment['payment_method'])),
          Text(saleText(payment['reference_no'])),
          Text(formatSaleDate(payment['payment_date'])),
          Wrap(
            children: [
              IconButton(
                tooltip: 'Edit'.tr,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete'.tr,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
