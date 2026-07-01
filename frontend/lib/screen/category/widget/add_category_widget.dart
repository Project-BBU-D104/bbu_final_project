import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:get/get.dart';

class AddCategoryWidget extends StatelessWidget {
  AddCategoryWidget({super.key});

  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Category",
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

          Text("Category Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            decoration: InputDecoration(
              hintText: "Category Name",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Icon", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            decoration: InputDecoration(
              hintText: "Icon",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 10),

          Text("Description", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
          SizedBox(height: 5,),
          const TextField(
            maxLines: 8,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "Description",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
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
                ctr.onSaveCategory();
              },
              child: const Text("Save", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
            ),
          ),
        ],
      ),
    );
  }
}