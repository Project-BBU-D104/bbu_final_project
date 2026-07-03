import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/user/widget/add_user_widget.dart';
import 'package:frontend/screen/user/widget/edit_user_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class UserController extends GetxController{

  var selectedUser = RxnString();
  var isChecked = false.obs;

  final List<UserModel> userList = [
  UserModel(
    id: 1,
    roleId: 1,
    username: "superadmin",
    email: "superadmin@example.com",
    password: "\$2b\$12\$abcdefghijklmnopqrstuv1234567890abcdefg",
    disable: false,
    createdAt: DateTime.parse("2026-07-01 08:00:00"),
    updatedAt: DateTime.parse("2026-07-01 08:00:00"),
  ),

  UserModel(
    id: 2,
    roleId: 2,
    
    username: "admin",
    email: "admin@example.com",
    password: "\$2b\$12\$hijklmnopqrstuvabcdef1234567890abcdefghij",
    disable: false,
    createdAt: DateTime.parse("2026-07-01 08:10:00"),
    updatedAt: DateTime.parse("2026-07-01 08:10:00"),
  ),

  UserModel(
    id: 3,
    roleId: 3,
    
    username: "manager",
    email: "manager@example.com",
    password: "\$2b\$12\$mnopqrstuvwxyz1234567890abcdefghijklmnop",
    disable: false,
    createdAt: DateTime.parse("2026-07-01 08:20:00"),
    updatedAt: DateTime.parse("2026-07-01 08:20:00"),
  ),

  UserModel(
    id: 4,
    roleId: 4,
    username: "cashier",
    email: "cashier@example.com",
    password: "\$2b\$12\$1234567890abcdefghijklmnopqrstuvabcdefghi",
    disable: false,
    createdAt: DateTime.parse("2026-07-01 08:30:00"),
    updatedAt: DateTime.parse("2026-07-01 08:30:00"),
  ),

  UserModel(
    id: 5,
    roleId: 8,
    username: "accountant",
    email: "accountant@example.com",
    password: "\$2b\$12\$uvwxyzabcdefghijk1234567890mnopqrstuvwxy",
    disable: true,
    createdAt: DateTime.parse("2026-07-01 08:40:00"),
    updatedAt: DateTime.parse("2026-07-01 08:40:00"),
  ),
];

  void addUser(BuildContext context){
    AppBottomSheets.show(
      context,
      child: AddUserWidget()
    );
  }

  void gotoUserDetail(UserModel user){
    Get.toNamed(
      AppRoutes.userDetail,
      arguments: user,
    );
  }

  void editUser(BuildContext context, Map<String, dynamic> user){
    AppBottomSheets.show(
      context,
      child: EditUserWidget()
    );
  }

  void deleteUser(BuildContext context, Map<String, dynamic> user){
    
  }
}