import 'package:flutter/material.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController{
  final customerList = [
    {
      'id': 1,
      'name': "John Doe",
      'photo': "https://i.pravatar.cc/150?img=12",
      'phone': '01234567890',
      'address': '30 street, New York, USA',
      'created_at': '2023-08-01',
    },
    {
      'id': 2,
      'name': "Jsmith Doe",
      'photo': "https://i.pravatar.cc/150?img=12",
      'phone': '0163425567890',
      'address': '30 street, New York, USA',
      'created_at': '2023-08-01',
    },
    {
      'id': 3,
      'name': "Jssmidth Doe",
      'photo': "https://i.pravatar.cc/150?img=12",
      'phone': '01234567890',
      'address': '30 street, New York, USA',
      'created_at': '2023-08-01',
    },
    {
      'id': 4,
      'name': "Hsmith Doe",
      'photo': "https://i.pravatar.cc/150?img=12",
      'phone': '01234567890',
      'address': '30 street, New York, USA',
      'created_at': '2023-08-01',
    },
    {
      'id': 5,
      'name': "Fsmith does",
      'photo': "https://i.pravatar.cc/150?img=12",
      'phone': '01234567890',
      'address': '30 street, New York, USA',
      'created_at': '2023-08-01',
    },
  ];

  void addCustomer(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddCustomerWidget()
    );
  }

  void editCustomer(BuildContext context, Map<String, dynamic> customer){
    AppBottomSheets.show(
      context,
      child: EditCustomerWidget()
    );
  }

  void onDeleteCustomer(int id){
    print("Delete customer with ID: $id");
  }
}