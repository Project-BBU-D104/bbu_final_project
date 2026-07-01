import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController{

  final List<Map<String, dynamic>> warehouseList = [
    {
      "id": 1,
      "name": "Main Warehouse",
      "location": "Phnom Penh",
    },
    {
      "id": 2,
      "name": "North Warehouse",
      "location": "Siem Reap",
    },
    {
      "id": 3,
      "name": "South Warehouse",
      "location": "Sihanoukville",
    },
    {
      "id": 4,
      "name": "East Warehouse",
      "location": "Kampong Cham",
    },
    {
      "id": 5,
      "name": "West Warehouse",
      "location": "Battambang",
    },
    {
      "id": 6,
      "name": "Outlet Warehouse",
      "location": "Poipet",
    },
    {
      "id": 7,
      "name": "Distribution Center",
      "location": "Takeo",
    },
    {
      "id": 8,
      "name": "Retail Warehouse",
      "location": "Kampot",
    },
    {
      "id": 9,
      "name": "Online Fulfillment",
      "location": "Kandal",
    },
    {
      "id": 10,
      "name": "Reserve Warehouse",
      "location": "Preah Sihanouk",
    },
  ];
  final List<Map<String, dynamic>> warehouseStockList = [
    {
      "id": 1,
      "product_id": 1,
      "warehouse_id": 1,
      "qty": 150,
    },
    {
      "id": 2,
      "product_id": 2,
      "warehouse_id": 1,
      "qty": 85,
    },
    {
      "id": 3,
      "product_id": 3,
      "warehouse_id": 2,
      "qty": 60,
    },
    {
      "id": 4,
      "product_id": 4,
      "warehouse_id": 2,
      "qty": 120,
    },
    {
      "id": 5,
      "product_id": 5,
      "warehouse_id": 3,
      "qty": 40,
    },
    {
      "id": 6,
      "product_id": 6,
      "warehouse_id": 4,
      "qty": 200,
    },
    {
      "id": 7,
      "product_id": 7,
      "warehouse_id": 5,
      "qty": 95,
    },
    {
      "id": 8,
      "product_id": 8,
      "warehouse_id": 6,
      "qty": 75,
    },
    {
      "id": 9,
      "product_id": 9,
      "warehouse_id": 7,
      "qty": 30,
    },
    {
      "id": 10,
      "product_id": 10,
      "warehouse_id": 8,
      "qty": 110,
    },
  ];

  void addWarehouse(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddWarehouseWidget()
    ); 
  }
}
