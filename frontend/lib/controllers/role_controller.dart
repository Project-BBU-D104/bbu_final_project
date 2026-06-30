import 'package:flutter/material.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class RoleController extends GetxController{

var isChecked = false.obs;


  void addRole(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddRoleWidget()
    );
  }
}
