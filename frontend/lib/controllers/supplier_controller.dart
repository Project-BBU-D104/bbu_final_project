import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_detail_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_edit_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class SupplierController extends GetxController {

  var isActive = false.obs;

  final selectedTab = "All".obs;

  final suppliers = <Map<String,String>>[

    {
      "name": "Alexander K. Sterling",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "map": "https://www.google.com/maps/place/30+St.+Brooklyn/@40.678178,-73.944158,17z/data=!3m1!4b1!4m6!3m5!1s0x89c25a316f8e7d9f:0x2c8e5b8e5b8e5b8e!8m2!3d40.678178!4d-73.944158!16s%2Fg%2F11c4z5v5k7",
      "icon": "🚀",
    },
    {
      "name": "Samantha J. Smith",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Pending",
      "created_at": "4 Days ago",
      "map": "https://www.google.com/maps/place/30+St.+Brooklyn/@40.678178,-73.944158,17z/data=!3m1!4b1!4m6!3m5!1s0x89c25a316f8e7d9f:0x2c8e5b8e5b8e5b8e!8m2!3d40.678178!4d-73.944158!16s%2Fg%2F11c4z5v5k7",
      "icon": "🚀",
    },
    {
      "name": "adam J. Smith",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "map": "https://www.google.com/maps/place/30+St.+Brooklyn/@40.678178,-73.944158,17z/data=!3m1!4b1!4m6!3m5!1s0x89c25a316f8e7d9f:0x2c8e5b8e5b8e5b8e!8m2!3d40.678178!4d-73.944158!16s%2Fg%2F11c4z5v5k7",
      "icon": "🚀",
    },
    {
      "name": "fred J. Smith",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "map": "https://www.google.com/maps/place/Baked+In+Brooklyn/@40.6582092,-74.0018071,17z/data=!4m15!1m8!3m7!1s0x89c25ac1e7dbf743:0x5f9b8b07ac052a81!2s30th+St,+Brooklyn,+NY+11232,+USA!3b1!8m2!3d40.6582092!4d-74.0018071!16s%2Fg%2F1tdwq__7!3m5!1s0x89c25ae83da32a1d:0x27bb819eb81682b5!8m2!3d40.6588667!4d-73.9963083!16s%2Fg%2F11_q32321?entry=ttu&g_ep=EgoyMDI2MDYyOC4wIKXMDSoASAFQAw%3D%3D",
      "icon": "🚀",
    },
  ].obs;

  void changeTab(String value){
    selectedTab.value = value;
  }

  void gotoSupplierDetail(Map<String,String> supplier){
    Get.toNamed(AppRoutes.supplierDetail, arguments: supplier);
  }

  void addSupplier(BuildContext context){
    AppBottomSheets.show(
      context,
      child: SupplierAddWidget()
    );
  }

  void editSupplier(BuildContext context){
    AppBottomSheets.show(
      context,
      child: SupplierEditWidget()
    );
  }

  void saveSupplier(){
    // Implement save supplier logic here
  }

  void deleteSupplier({required int supplierId}){
    print("Delete supplier with ID: $supplierId");
  }

}