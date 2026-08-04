import 'package:flutter/material.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/widget/unit_card_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class UnitScreen extends StatelessWidget {
  UnitScreen({super.key});

  final ctr = Get.put(UnitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Unit"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Unit"),

              SizedBox(height: 16),

              Obx(()
                {
                  if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (ctr.unitList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text("No Unit Found".tr),
                      ),
                    );
                  }
 
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctr.unitList.length,
                    itemBuilder: (context, index){
                      final unit = ctr.unitList[index];
                      return UnitCardWidget(units: unit,);
                    },
                  );
                }
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addUnit(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}