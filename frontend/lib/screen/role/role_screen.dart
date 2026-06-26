import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class RoleScreen extends StatelessWidget {
  RoleScreen({super.key});
  
  final ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Role Screen")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchWidget(title: "Search Role"),
            RoleCardWidget(),
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addRole(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}