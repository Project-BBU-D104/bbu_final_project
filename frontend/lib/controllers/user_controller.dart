import 'package:flutter/material.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:get/get.dart';

class UserController extends GetxController{

  var selectedUser = RxnString();

  var isChecked = false.obs;

  void addUser(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddUserWidget(); 
      }
    );
  }
}