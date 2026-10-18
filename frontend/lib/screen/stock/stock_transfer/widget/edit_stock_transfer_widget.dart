import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';

class EditStockTransferWidget extends StatelessWidget {
  const EditStockTransferWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AddStockTransferWidget(isEditing: true);
  }
}
