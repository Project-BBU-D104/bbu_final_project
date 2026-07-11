import 'package:flutter/material.dart';
import 'package:frontend/controllers/image_upload_controller.dart';
import 'package:get/get.dart';

class ImageUploadWidget extends StatelessWidget {

  ImageUploadWidget({
    super.key,
    this.imageUrl,
    required this.onUploaded,
    required this.bucket,
    this.folder = "",
  });


  final String? imageUrl;
  final Function(String url) onUploaded;

  /// Supabase bucket name
  final String bucket;

  /// Optional folder inside bucket
  final String folder;

  final ctr = Get.put(ImageUploadController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
            BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            /// IMAGE PREVIEW
            if (ctr.file.value != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),
                child: Image.file(
                  ctr.file.value!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else if (imageUrl != null &&
                     imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),

                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (context, error, stackTrace) {

                    return const Icon(
                      Icons.broken_image,
                      size: 80,
                    );
                  },
                ),
              )
            else
              const Icon(
                Icons.image,
                size: 80,
              ),
            const SizedBox(height: 10),
            /// PICK + UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ctr.loading.value
                    ? null
                    : () async {
                        await ctr.pickImage();
                        final url =
                            await ctr.uploadImage(
                              bucket: bucket,
                              folder: folder,
                            );
                        if (url != null) {
                          onUploaded(url);
                        }
                      },
                icon: ctr.loading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                      )
                    : const Icon(
                        Icons.photo,
                      ),
                label: Text(
                  ctr.loading.value
                      ? "Uploading..."
                      : "Upload Image".tr,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}