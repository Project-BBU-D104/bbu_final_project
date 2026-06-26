import 'package:flutter/material.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:get/get.dart';

class RoleController extends GetxController{

var isChecked = false.obs;


  void addRole(BuildContext context){
     showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return AddRoleWidget(); 
    }
  );
  }
  }
