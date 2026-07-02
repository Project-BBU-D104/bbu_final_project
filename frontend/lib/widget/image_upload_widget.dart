import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:get/get.dart';

class ImageUploadWidget extends StatelessWidget {
  ImageUploadWidget({super.key, required this.onUploaded});

  final Function(String url) onUploaded;
  final ctr = Get.put(ImageUploadController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [

            /// PREVIEW IMAGE
            ctr.file.value != null
                ? Image.file(ctr.file.value!, height: 120)
                : const Icon(Icons.image, size: 80),

            const SizedBox(height: 10),

            /// PICK BUTTON ONLY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ctr.pickImage,
                icon: const Icon(Icons.photo),
                label: Text("Pick Image".tr),
              ),
            ),
          ],
        ),
      );
    });
  }
}