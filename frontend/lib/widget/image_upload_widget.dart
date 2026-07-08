import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:get/get.dart';

class ImageUploadWidget extends StatelessWidget {
  ImageUploadWidget({
    super.key,
    this.imageUrl,
    required this.onUploaded,
  });

  final String? imageUrl;
  final Function(String url) onUploaded;

  final ctr = Get.find<ImageUploadController>();

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
            if (ctr.file.value != null)
              Image.file(
                ctr.file.value!,
                height: 120,
                fit: BoxFit.cover,
              )
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                height: 120,
                fit: BoxFit.cover,
              )
            else
              const Icon(
                Icons.image,
                size: 80,
              ),

            const SizedBox(height: 10),

            /// PICK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {

                  await ctr.pickImage();

                  final url = await ctr.uploadImage();

                  if (url != null) {
                    onUploaded(url);
                  }
                },
                icon: const Icon(Icons.photo),
                label: Text("Upload Image".tr),
              ),
            ),
          ],
        ),
      );
    });
  }
}