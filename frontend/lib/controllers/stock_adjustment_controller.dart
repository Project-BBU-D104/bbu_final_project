import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController{
  void addStockAdjustment(BuildContext context){
     showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AddStockAdjustmentWidget(); 
    }
  );
  }
}