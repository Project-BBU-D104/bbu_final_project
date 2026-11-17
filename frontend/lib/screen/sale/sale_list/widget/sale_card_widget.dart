import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_status_badge.dart';
import 'package:get/get.dart';

class SaleCardWidget extends StatelessWidget {
  const SaleCardWidget({super.key, required this.sale, this.onTap});
  final Map<String, dynamic> sale;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => AppListCard(
    onTap:
        onTap ?? () => Get.find<SaleListController>().gotoSaleListDetail(sale),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(saleText(sale['invoice_no'])),
        Text(saleText(saleMap(sale['customer'])['name'])),
        Text(formatSaleDate(sale['sale_date'])),
        Text(formatSaleAmount(sale['total_amount'])),
        Text('${'Paid'.tr}: ${formatSaleAmount(sale['paid_amount'])}'),
        Text('${'Due'.tr}: ${formatSaleAmount(sale['due_amount'])}'),
        AppStatusBadge(
          label: salePaymentStatusLabel(sale['payment_status']),
          tone: salePaymentStatusTone(sale['payment_status']),
        ),
      ],
    ),
  );
}
