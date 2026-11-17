import 'package:flutter/material.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';

class SaleTableWidget extends StatelessWidget {
  const SaleTableWidget({super.key, required this.sales, required this.onOpen});
  final List<Map<String, dynamic>> sales;
  final ValueChanged<Map<String, dynamic>> onOpen;
  @override
  Widget build(BuildContext context) => AppTable<Map<String, dynamic>>(
    rows: sales,
    onRowTap: onOpen,
    columns: [
      for (final entry in {
        'Invoice': 'invoice_no',
        'Customer': 'customer',
        'Date': 'sale_date',
        'Total': 'total_amount',
        'Paid': 'paid_amount',
        'Due': 'due_amount',
        'Payment status': 'payment_status',
      }.entries)
        AppTableColumn(
          title: entry.key,
          builder: (context, sale) => Text(switch (entry.value) {
            'customer' => saleText(saleMap(sale['customer'])['name']),
            'sale_date' => formatSaleDate(sale['sale_date']),
            'total_amount' ||
            'paid_amount' ||
            'due_amount' => formatSaleAmount(sale[entry.value]),
            'payment_status' => salePaymentStatusLabel(sale[entry.value]),
            _ => saleText(sale[entry.value]),
          }),
        ),
    ],
  );
}
