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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
           
              SearchWidget(title: "Search User...".tr),
              SizedBox(height: 12),
              Obx(() {
                final activeUsers = ctr.userList
                    .where((user) => user["is_active"] == true)
                    .length;
                final inactiveUsers = ctr.userList.length - activeUsers;

                return SizedBox(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: KpiUserWidget(
                          title: "Active Users",
                          value: activeUsers,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: KpiUserWidget(
                          value: inactiveUsers,
                          title: "Inactive Users",
                        ),
                      ),
                    ],
                  ),
                );
              }),
          
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text("${ctr.userList.length} Users")),
                
                  ElevatedButton(
                    onPressed: (){
                      ctr.addUser(context);
                    }, 
                    child: Text("New User".tr)
                  )
                ],
              ),

              SizedBox(height: 15),
              
              Obx(
                () => ctr.isLoading.value
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ctr.userList.isEmpty
                        ? Center(child: Text("No User Found".tr))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ctr.userList.length,
                            itemBuilder: (context, index) =>
                                UserCardListWidget(
                                  user: ctr.userList[index],
                                ),
                          ),
              ),
          
            ],
          ),
        ),
      )
    );
  }
}