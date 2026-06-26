import 'package:flutter/material.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController{
  void addWarehouse(BuildContext context){
      showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AddWarehouseWidget(); 
    }
  );
  }
  }
