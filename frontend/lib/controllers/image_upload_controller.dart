import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ImageUploadController extends GetxController {
  final picker = ImagePicker();

  var file = Rxn<File>();
  var imageUrl = "".obs;
  var loading = false.obs;

  /// PICK IMAGE (ANDROID + WINDOWS)
  Future<void> pickImage() async {
    if (kIsWeb) return;

    if (Platform.isAndroid || Platform.isIOS) {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        file.value = File(picked.path);
      }
    } else {
      // WINDOWS / DESKTOP
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        file.value = File(result.files.single.path!);
      }
    }
  }

  /// UPLOAD IMAGE (SAME FOR ALL PLATFORMS)
  Future<String?> uploadImage() async {
    if (file.value == null) return null;

    loading.value = true;

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://10.0.2.2:8000/upload-image"),
      );

      request.files.add(
        await http.MultipartFile.fromPath("image", file.value!.path),
      );

      var response = await request.send();
      var res = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(res);
        imageUrl.value = data["image_url"];
        return imageUrl.value;
      }

      return null;
    } finally {
      loading.value = false;
    }
  }
}