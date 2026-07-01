import 'package:flutter/material.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class UserController extends GetxController{

  var selectedUser = RxnString();
  var isChecked = false.obs;

  final List<Map<String, dynamic>> userList = [
    {
      "id": 1,
      "role_id": 1,
      "role_name": "Super Admin",
      "username": "superadmin",
      "email": "superadmin@example.com",
      "password": "\$2b\$12\$abcdefghijklmnopqrstuv1234567890abcdefg", // hashed password
      "disable": false,
      "created_at": "2026-07-01 08:00:00",
      "updated_at": "2026-07-01 08:00:00",
    },
    {
      "id": 2,
      "role_id": 2,
      "role_name": "Admin",
      "username": "admin",
      "email": "admin@example.com",
      "password": "\$2b\$12\$hijklmnopqrstuvabcdef1234567890abcdefghij",
      "disable": false,
      "created_at": "2026-07-01 08:10:00",
      "updated_at": "2026-07-01 08:10:00",
    },
    {
      "id": 3,
      "role_id": 3,
      "role_name": "Manager",
      "username": "manager",
      "email": "manager@example.com",
      "password": "\$2b\$12\$mnopqrstuvwxyz1234567890abcdefghijklmnop",
      "disable": false,
      "created_at": "2026-07-01 08:20:00",
      "updated_at": "2026-07-01 08:20:00",
    },
    {
      "id": 4,
      "role_id": 4,
      "role_name": "Cashier",
      "username": "cashier",
      "email": "cashier@example.com",
      "password": "\$2b\$12\$1234567890abcdefghijklmnopqrstuvabcdefghi",
      "disable": false,
      "created_at": "2026-07-01 08:30:00",
      "updated_at": "2026-07-01 08:30:00",
    },
    {
      "id": 5,
      "role_id": 8,
      "role_name": "Accountant",
      "username": "accountant",
      "email": "accountant@example.com",
      "password": "\$2b\$12\$uvwxyzabcdefghijk1234567890mnopqrstuvwxy",
      "disable": true,
      "created_at": "2026-07-01 08:40:00",
      "updated_at": "2026-07-01 08:40:00",
    },
  ];

  void addUser(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddUserWidget()
    );
  }
}