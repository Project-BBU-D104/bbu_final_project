import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_form_widget.dart';
import 'package:get/get.dart';

class EditStockTransferWidget extends StatelessWidget {
  const EditStockTransferWidget({super.key});
  @override
  Widget build(BuildContext context) => StockTransferFormWidget(
    stockTransfer: Get.find<ProductTransferController>().editingTransfer.value,
  );
}
