import 'package:get/get.dart';

class SearchController extends GetxController {
  final RxString keyword = ''.obs;

  @override
  void onInit() {
    super.onInit();

    debounce(keyword, (value) {
      keyword.value = value.trim();
    }, time: const Duration(milliseconds: 500));
  }

  void clear() {
    keyword.value = '';
  }
}
