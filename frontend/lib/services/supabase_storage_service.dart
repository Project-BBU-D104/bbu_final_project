import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {

  SupabaseClient get supabase =>
      Supabase.instance.client;


  Future<String?> uploadImage(File file) async {

    try {

      final filename =
          "${DateTime.now().millisecondsSinceEpoch}.jpg";


      final path =
          "customers/$filename";


      await supabase.storage
          .from("customer")
          .upload(
            path,
            file,
          );


      final url =
          supabase.storage
          .from("customer")
          .getPublicUrl(path);


      return url;


    } catch(e) {

      print(
        "Supabase upload error: $e"
      );

      return null;

    }

  }

}