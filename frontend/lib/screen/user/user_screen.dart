import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/user/widget/kpi_user_widget.dart';
import 'package:frontend/screen/user/widget/user_card_list_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class UserScreen extends StatelessWidget {
   UserScreen({super.key});

  final ctr = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "User"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
          
              SizedBox(height: 8),
              SearchWidget(title: "Search User...".tr),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KpiUserWidget(
                        title: "Active Users",
                        value: 100,
                      ),
                    ),
                    Expanded(
                      child: KpiUserWidget(
                        title: "Inactive Users",
                        value: 100,
                      ),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("100 Users"),
                
                  ElevatedButton(
                    onPressed: (){
                      ctr.addUser(context);
                    }, 
                    child: Text("New User".tr)
                  )
                ],
              ),

              SizedBox(height: 15),
              UserCardListWidget(),
          
            ],
          ),
        ),
      )
    );
  }
}