import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/ui/app_table.dart';
import 'package:get/get.dart';

class StockTransferTableWidget extends StatelessWidget {
  const StockTransferTableWidget({super.key, required this.stockTransfers});
  final List<Map<String, dynamic>> stockTransfers;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProductTransferController>();
    return AppTable<Map<String, dynamic>>(
      rows: stockTransfers,
      onRowTap: c.gotoStockTransferDetail,
      columns: [
        AppTableColumn(
          title: 'Reference number',
          builder: (context, row) =>
              AppTableColumn.value(context, row['reference_no']?.toString()),
        ),
        AppTableColumn(
          title: 'From warehouse',
          builder: (context, row) => AppTableColumn.value(
            context,
            transferWarehouse(row, 'from_warehouse'),
          ),
        ),
        AppTableColumn(
          title: 'To warehouse',
          builder: (context, row) => AppTableColumn.value(
            context,
            transferWarehouse(row, 'to_warehouse'),
          ),
        ),
        AppTableColumn(
          title: 'Total quantity',
          builder: (context, row) => Text('${transferTotal(row)}'),
        ),
        AppTableColumn(
          title: 'Transfer date',
          builder: (context, row) => Text(transferDate(row)),
        ),
        AppTableColumn(
          title: 'Actions',
          builder: (context, row) => Wrap(
            children: [
              IconButton(
                tooltip: 'Edit'.tr,
                onPressed: () => c.editStockTransfer(context, row),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete'.tr,
                onPressed: () => c.onDeleteStockTransfer(context, row['id']),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
