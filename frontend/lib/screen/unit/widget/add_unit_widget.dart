import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:get/get.dart';

class AddUnitWidget extends StatelessWidget {
  AddUnitWidget({super.key});

  final ctr = Get.put(UnitController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Unit".tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text("Unit Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.unitNameController,
            decoration: InputDecoration(
              hintText: "Enter Unit".tr,
              border: OutlineInputBorder(),
            ),
          ),
 
          const SizedBox(height: 10),

          Text("Short Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.unitShortNameController,
            decoration: InputDecoration(
              hintText: "Enter Short Name".tr,
              border: OutlineInputBorder(),
            ),
          ),
 
          const SizedBox(height: 10),

          Text("Description".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          TextField(
            controller: ctr.unitDescriptionController,
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Enter Description".tr,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),
        
           Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: ctr.isActive.value,
                    onChanged: (value) {
                      ctr.isActive.value = value ?? false;
                    },
                  ),
                  const Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ctr.onSaveUnit();
              },
              child: Text(
                "Save".tr,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
              )
            ),
          ),
        ],
      ),
    );
  }
}