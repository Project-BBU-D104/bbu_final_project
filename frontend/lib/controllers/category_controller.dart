import 'package:frontend/services/api_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final api = ApiService();

  final categoryList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCategory();
  }

  Future<void> getCategory() async {
    try {
      isLoading.value = true;

      final resp = await api.get("category/");
    if (resp is List) {
        categoryList.value = List<Map<String, dynamic>>.from(resp);
    }
    
    } catch (e) {
      print("Error getCategory: $e");
    } finally {
      isLoading.value = false;
    }
  }
}