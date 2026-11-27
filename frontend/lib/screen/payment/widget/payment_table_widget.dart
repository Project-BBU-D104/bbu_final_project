import 'package:flutter/material.dart';
import 'package:frontend/screen/payment/widget/payment_actions_widget.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';

class PaymentTableWidget extends StatelessWidget {
  const PaymentTableWidget({
    super.key,
    required this.payments,
    required this.onEdit,
    required this.onDelete,
  });
  final List<Map<String, dynamic>> payments;
  final ValueChanged<Map<String, dynamic>> onEdit, onDelete;
  @override
  Widget build(BuildContext context) => AppTable<Map<String, dynamic>>(
    rows: payments,
    columns: [
      for (final entry in {
        'Invoice': 'invoice_no',
        'Customer': 'customer',
        'Amount': 'amount',
        'Method': 'payment_method',
        'Reference': 'reference_no',
        'Date': 'payment_date',
      }.entries)
        AppTableColumn(
          title: entry.key,
          builder: (context, p) => Text(switch (entry.value) {
            'invoice_no' => saleText(saleMap(p['sale'])['invoice_no']),
            'customer' => saleText(
              saleMap(saleMap(p['sale'])['customer'])['name'],
            ),
            'amount' => formatSaleAmount(p['amount']),
            'payment_date' => formatSaleDate(p['payment_date']),
            _ => saleText(p[entry.value]),
          }),
        ),
      AppTableColumn(
        title: 'Actions',
        builder: (context, p) => PaymentActionsWidget(
          onEdit: () => onEdit(p),
          onDelete: () => onDelete(p),
        ),
      ),
    ],
  );
}
