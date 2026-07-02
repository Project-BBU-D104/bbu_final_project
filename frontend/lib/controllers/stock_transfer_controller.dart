import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class StockTransferController extends GetxController{

  var selectedDate = Rxn<DateTime>();

  final List<Map<String, dynamic>> stockTransfer = [
    {
      "id": 1,
      "from_warehouse_id": 1,
      "from_warehouse_name": "Warehouse 1",
      "to_warehouse_id": 2,
      "to_warehouse_name": "Warehouse 2",
      "product_id": 1,
      "product_name": "Product 1",
      "qty": 20,
      "transfer_date": "2026-07-01",
      "status": "Completed",
      "created_at": "2026-07-01 08:30:00",
    },
    {
      "id": 2,
      "from_warehouse_id": 1,
      "from_warehouse_name": "Warehouse 1",
      "to_warehouse_id": 3,
      "to_warehouse_name": "Warehouse 3",
      "product_id": 2,
      "product_name": "Product 2",
      "qty": 15,
      "transfer_date": "2026-07-01",
      "status": "Pending",
      "created_at": "2026-07-01 09:15:00",
    },
    {
      "id": 3,
      "from_warehouse_id": 2,
      "from_warehouse_name": "Warehouse 2",
      "to_warehouse_id": 1,
      "to_warehouse_name": "Warehouse 1",
      "product_id": 3,
      "product_name": "Product 3",
      "qty": 30,
      "transfer_date": "2026-07-02",
      "status": "Completed",
      "created_at": "2026-07-02 10:45:00",
    },
    {
      "id": 4,
      "from_warehouse_id": 3,
      "from_warehouse_name": "Warehouse 3",
      "to_warehouse_id": 2,
      "to_warehouse_name": "Warehouse 2",
      "product_id": 4,
      "product_name": "Product 4",
      "qty": 12,
      "transfer_date": "2026-07-02",
      "status": "Cancelled",
      "created_at": "2026-07-02 13:20:00",
    },
    {
      "id": 5,
      "from_warehouse_id": 2,
      "from_warehouse_name": "Warehouse 2",
      "to_warehouse_id": 3,
      "to_warehouse_name": "Warehouse 3",
      "product_id": 5,
      "product_name": "Product 5",
      "qty": 8,
      "transfer_date": "2026-07-03",
      "status": "Completed",
      "created_at": "2026-07-03 09:10:00",
    },
    {
      "id": 6,
      "from_warehouse_id": 3,
      "from_warehouse_name": "Warehouse 3",
      "to_warehouse_id": 1,
      "to_warehouse_name": "Warehouse 1",
      "product_id": 6,
      "product_name": "Product 6",
      "qty": 50,
      "transfer_date": "2026-07-03",
      "status": "Pending",
      "created_at": "2026-07-03 11:40:00",
    },
    {
      "id": 7,
      "from_warehouse_id": 1,
      "to_warehouse_id": 2,
      "from_warehouse_name": "Warehouse 1",
      "to_warehouse_name": "Warehouse 2",
      "product_id": 7,
      "product_name": "Product 7",
      "qty": 18,
      "transfer_date": "2026-07-04",
      "status": "Completed",
      "created_at": "2026-07-04 08:55:00",
    },
    {
      "id": 8,
      "from_warehouse_id": 2,
      "to_warehouse_id": 1,
      "from_warehouse_name": "Warehouse 2",
      "to_warehouse_name": "Warehouse 1",
      "product_id": 8,
      "product_name": "Product 8",
      "qty": 40,
      "transfer_date": "2026-07-04",
      "status": "Pending",
      "created_at": "2026-07-04 14:30:00",
    },
    {
      "id": 9,
      "from_warehouse_id": 3,
      "from_warehouse_name": "Warehouse 3",
      "to_warehouse_id": 2,
      "to_warehouse_name": "Warehouse 2",
      "product_id": 9,
      "product_name": "Product 9",
      "qty": 25,
      "transfer_date": "2026-07-05",
      "status": "Completed",
      "created_at": "2026-07-05 10:15:00",
    },
    {
      "id": 10,
      "from_warehouse_id": 1,
      "from_warehouse_name": "Warehouse 1",
      "to_warehouse_id": 3,
      "to_warehouse_name": "Warehouse 3",
      "product_id": 10,
      "product_name": "Product 10",
      "qty": 35,
      "transfer_date": "2026-07-05",
      "status": "Cancelled",
      "created_at": "2026-07-05 16:45:00",
    },
  ];



  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    if (selectedDate.value == null) return "Select Date".tr;
    return selectedDate.value!.toString().split(" ")[0];
  }

  void addStockTransfer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddStockTransferWidget()
    );
  }

  void gotoStockTransferDetail(Map<String, dynamic> stockTransfer){
    Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
  }

  void editStockTransfer(BuildContext context, Map<String, dynamic> stockTransfer){
    AppBottomSheets.show(
      context,
      child: EditStockTransferWidget()
    );
  }

  void onDeleteStockTransfer(int id){
    print("Delete stock transfer with ID: $id");
  }
}