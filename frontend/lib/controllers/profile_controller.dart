import 'package:frontend/global.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController{

  final username = "".obs;
  final email = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserLogin();
  }

  void loadUserLogin() {
   final data = storage.lastUserLoginRead;

    if(data !=null ){
      final user = data["user"];

      if(user !=null){
        username.value = data["user"]["name"] ?? "";
        email.value = data["user"]["email"] ?? "";
      }
    }
  }

  void onLogoutPress(){
    Get.offAllNamed('/login');
  }
  
}