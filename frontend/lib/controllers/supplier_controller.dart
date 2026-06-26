import 'package:get/get.dart';

class SupplierController extends GetxController {


  final selectedTab = "All".obs;


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