import 'package:frontend/services/main_service/system_configuration_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SystemConfigurationController extends GetxController{

  final SystemConfigurationService service = SystemConfigurationService();

  final systemConfigurationList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSystemConfigurations();
  }

  Future<void> getSystemConfigurations() async {
    try {
      isLoading.value = true;

      final resp = await service.getSystemConfigurations();

      if (resp is List) {
        systemConfigurationList.value = List<Map<String, dynamic>>.from(resp);

        print("System Configurations: $systemConfigurationList");
      }
    } catch (e) {
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
    } finally {
        isLoading.value = false;
    }
  }

}