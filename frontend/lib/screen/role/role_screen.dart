import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class RoleScreen extends StatelessWidget {
  RoleScreen({super.key});
  
  final ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Role"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [

              
              SizedBox(height: 8,),
              SearchWidget(title: "Search Role"),
               SizedBox(height: 8,),
              
              Obx(() {

                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (ctr.roleList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        "No roles found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
                 return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctr.roleList.length,
                  itemBuilder: (context, index) => RoleCardWidget( role: ctr.roleList[index],),
                );
                }),
              SizedBox(height: 80,)
            ]
          ),
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