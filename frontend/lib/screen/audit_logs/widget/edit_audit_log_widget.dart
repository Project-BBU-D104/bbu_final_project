import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class EditAuditLogWidget extends StatelessWidget {
  const EditAuditLogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Audit Log".tr,
                  style: TextStyle(
                    fontSize: 18,
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
      
            Text("Title".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Title".tr,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
      
            Text("Action".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Action".tr,
                border: OutlineInputBorder(),
              ),
            ),
      
            const SizedBox(height: 10),
            Text("Table Name".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Table Name".tr,
                border: OutlineInputBorder(),
              ),
            ),
      
            const SizedBox(height: 10),
            Text("Record ID".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
             TextField(
               
                decoration: InputDecoration(
                  hintText: "Select Record Id".tr,
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 10),
            Text("Old Value".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
             TextField(
               maxLines: 8,
               minLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter Old Value".tr,
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 10),
            Text("New Value".tr, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 5),
             TextField(
               maxLines: 8,
               minLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter New Value".tr,
                  border: OutlineInputBorder(),
                ),
              ),
      
            const SizedBox(height: 15),
      
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
                  foregroundColor: titleColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Save".tr, style: TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}