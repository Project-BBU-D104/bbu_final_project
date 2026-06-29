import 'package:flutter/material.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:get/get.dart';

class SupplierController extends GetxController {


  final selectedTab = "All".obs;

  void addSupplier(BuildContext context){
       showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SupplierAddWidget(); 
    }
  );
  }


  final suppliers = <Map<String,String>>[

    {
      "name": "Alexander K. Sterling",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "icon": "🚀",
    },
    {
      "name": "Alexander2 K. Sterling",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Pending",
      "created_at": "4 Days ago",
      "icon": "🚀",
    },
    {
      "name": "Alexander K. Sterling",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "icon": "🚀",
    },
    {
      "name": "Alexander K. Sterling",
      "email": "2A2kW@example.com",
      "phone": "+855 (012) 345-678",
      "address": "30 St. Brooklyn",
      "status": "Verified",
      "created_at": "4 Days ago",
      "icon": "🚀",
    },


   


  ].obs;



  void changeTab(String value){

    selectedTab.value = value;

  }

}