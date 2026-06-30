import 'package:flutter/material.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class UserController extends GetxController{

  var selectedUser = RxnString();

  var isChecked = false.obs;

  void addUser(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddUserWidget()
    );
  }
}