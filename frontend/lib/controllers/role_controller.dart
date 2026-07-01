import 'package:flutter/material.dart';
import 'package:frontend/screen/role/widget/add_role_widget.dart';
import 'package:frontend/screen/role/widget/edit_role_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class RoleController extends GetxController{

var isChecked = false.obs;

  final List<Map<String, dynamic>> roleList = [
  {
    "id": 1,
    "name": "Super Admin",
    "description": "Has full access to all modules and system settings.",
    "is_active": true,
    "created_at": "2026-07-01 08:00:00",
    "updated_at": "2026-07-01 08:00:00",
  },
  {
    "id": 2,
    "name": "Administrator",
    "description": "Manages users, inventory, and business operations.",
    "is_active": true,
    "created_at": "2026-07-01 08:05:00",
    "updated_at": "2026-07-01 08:05:00",
  },
  {
    "id": 3,
    "name": "Manager",
    "description": "Oversees daily operations and approves transactions.",
    "is_active": true,
    "created_at": "2026-07-01 08:10:00",
    "updated_at": "2026-07-01 08:10:00",
  },
  {
    "id": 4,
    "name": "Cashier",
    "description": "Handles sales, payments, and customer transactions.",
    "is_active": true,
    "created_at": "2026-07-01 08:15:00",
    "updated_at": "2026-07-01 08:15:00",
  }
];

  void addRole(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddRoleWidget()
    );
  }

  void editRole(BuildContext context, Map<String, dynamic> role){
    AppBottomSheets.show(
      context,
      child: EditRoleWidget()
    );
  }

  void onDeleteRole(int roleId) {
    print("Delete role with ID: $roleId");
  }
}
