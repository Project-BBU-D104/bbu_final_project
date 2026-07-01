import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController{
  
  final stockAdjustmentList = [
  {
    "id": "SA0001",
    "product_id": "PROD001",
    "product_name": "iPhone 15 Pro",
    "warehouse_id": "WH001",
    "warehouse_name": "Main Warehouse",
    "user_id": "USER001",
    "user_name": "Admin",
    "adjustment_type": "increase",
    "qty": 20,
    "previous_qty": 50,
    "new_qty": 70,
    "reason": "New stock received",
    "reference_no": "ADJ-20260701-001",
    "created_at": DateTime.now(),
    "updated_at": DateTime.now(),
  },
  {
    "id": "SA0002",
    "product_id": "PROD002",
    "product_name": "Logitech Mouse",
    "warehouse_id": "WH001",
    "warehouse_name": "Main Warehouse",
    "user_id": "USER002",
    "user_name": "Manager",
    "adjustment_type": "decrease",
    "qty": 5,
    "previous_qty": 40,
    "new_qty": 35,
    "reason": "Damaged products",
    "reference_no": "ADJ-20260701-002",
    "created_at": DateTime.now(),
    "updated_at": DateTime.now(),
  },
  {
    "id": "SA0003",
    "product_id": "PROD003",
    "product_name": "Mechanical Keyboard",
    "warehouse_id": "WH002",
    "warehouse_name": "Branch Warehouse",
    "user_id": "USER001",
    "user_name": "Admin",
    "adjustment_type": "increase",
    "qty": 10,
    "previous_qty": 15,
    "new_qty": 25,
    "reason": "Stock correction",
    "reference_no": "ADJ-20260701-003",
    "created_at": DateTime.now(),
    "updated_at": DateTime.now(),
  },
  {
    "id": "SA0004",
    "product_id": "PROD004",
    "product_name": "Samsung 27\" Monitor",
    "warehouse_id": "WH001",
    "warehouse_name": "Main Warehouse",
    "user_id": "USER003",
    "user_name": "Warehouse Staff",
    "adjustment_type": "decrease",
    "qty": 2,
    "previous_qty": 18,
    "new_qty": 16,
    "reason": "Display unit removed",
    "reference_no": "ADJ-20260701-004",
    "created_at": DateTime.now(),
    "updated_at": DateTime.now(),
  },
  {
    "id": "SA0005",
    "product_id": "PROD005",
    "product_name": "USB-C Charger",
    "warehouse_id": "WH002",
    "warehouse_name": "Branch Warehouse",
    "user_id": "USER002",
    "user_name": "Manager",
    "adjustment_type": "increase",
    "qty": 50,
    "previous_qty": 120,
    "new_qty": 170,
    "reason": "Supplier replacement",
    "reference_no": "ADJ-20260701-005",
    "created_at": DateTime.now(),
    "updated_at": DateTime.now(),
  },
];

  void addStockAdjustment(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddStockAdjustmentWidget()
    );
  }

  void editStockAdjustment(BuildContext context, Map<String, dynamic> stockAdjustment){
    AppBottomSheets.show(
      context,
      child: EditStockAdjustmentTypeWidget()
    );
  }

  void onDeleteStockAdjustment(int id){
    print("Delete stock adjustment with ID: $id");
  }

  void gotoStockAdjustmentDetailScreen(Map<String, dynamic> stockAdjustment){
    Get.toNamed(AppRoutes.stockAdjustmentDetail, arguments: stockAdjustment);
  }
}