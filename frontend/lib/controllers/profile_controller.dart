import 'package:get/get.dart';

class ProfileController extends GetxController{
  void onLogoutPress(){
    Get.offAllNamed('/login');
  }
}