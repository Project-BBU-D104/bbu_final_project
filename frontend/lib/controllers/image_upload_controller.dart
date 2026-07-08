import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/services/supabase_storage_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadController extends GetxController {
  final picker = ImagePicker();
  final storage =
      SupabaseStorageService();

  var file = Rxn<File>();
  var imageUrl = "".obs;
  var loading = false.obs;

  Future<void> pickImage() async {

    if(kIsWeb){
      return;
    }

    if(Platform.isAndroid || Platform.isIOS){

      final picked =
          await picker.pickImage(
            source: ImageSource.gallery,
          );
      if(picked != null){

        file.value =
            File(picked.path);
      }

    }else{

      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
            type: FileType.image,
          );

      if(result != null){

        file.value =
            File(
              result.files.single.path!,
            );
      }
    }
  }

  void clearImage() {
    file.value = null;
    imageUrl.value = "";
  }

  Future<String?> uploadImage() async {
    if(file.value == null){
      return null;
    }
    loading.value = true;
    try{
      final url =
          await storage.uploadImage(
            file.value!,
          );
      if(url != null){
        imageUrl.value = url;
        return url;
      }
      return null;
    }finally{
      loading.value = false;
    }
  }
}