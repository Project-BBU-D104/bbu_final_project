import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_form_widget.dart';
import 'package:get/get.dart';

class AddStockTransferWidget extends StatelessWidget {
  const AddStockTransferWidget({super.key, this.isEditing = false});
  final bool isEditing;
  @override
  Widget build(BuildContext context) => StockTransferFormWidget(
    stockTransfer: isEditing
        ? Get.find<ProductTransferController>().editingTransfer.value
        : null,
  );
}
