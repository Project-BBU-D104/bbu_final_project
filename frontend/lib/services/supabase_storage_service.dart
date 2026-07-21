
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseClient get supabase =>
      Supabase.instance.client;

  Future<String?> uploadImage({
    required File file,
    required String bucket,
    String folder = "",
  }) async {
    try {
      final filename =
          "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = folder.isNotEmpty
          ? "$folder/$filename"
          : filename;
      await supabase.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      final url =
          supabase.storage
              .from(bucket)
              .getPublicUrl(path);
      return url;
    } catch (e) {
    
      return null;
    }
  }
  Future<bool> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await supabase.storage
          .from(bucket)
          .remove([path]);
      return true;
    } catch(e) {
      
      return false;
    }
  }
}