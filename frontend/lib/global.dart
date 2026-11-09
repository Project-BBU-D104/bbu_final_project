import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/screen/supplier/location_picker_page.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:latlong2/latlong.dart';

//// Variables
// final storage = GetStorage(".appsettings");
// final app = locator<IAppService>();

final storage = locator<IStorageService>();

String appName = "ePOS App";
String deviceID = "";
String appVersion = "0.0.0";

String serverUrl = "";

// convert to UPPER_SNAKE_CASE
String toUpperSnakeCase(String input) {
  return input
      .replaceAllMapped(
        // ignore: deprecated_member_use
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m.group(1)}_${m.group(2)}',
      )
      .toUpperCase();
}

///Future Delayed 250 milliseconds default
Future<void> onDelayed([Duration? duration]) async {
  await Future.delayed(duration ?? const Duration(milliseconds: 250));
}

Future<void> closeSnackbar() async {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
    await Future.delayed(const Duration(seconds: 100));
  }
}

//Toaster (snackbar)
SnackbarController? snackController;
getSnackbar_({
  required String title,
  required String description,
  required Icon icon,
  Color foreground = Colors.white,
  required Color background,
}) {
  snackController = Get.snackbar(
    title,
    description,
    maxWidth: 500,
    padding: const EdgeInsets.symmetric(vertical: 10),
    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
    backgroundColor: background,
    icon: icon,
    colorText: foreground,
    snackPosition: SnackPosition.TOP,
    overlayBlur: 0,
    shouldIconPulse: true,
    barBlur: 20,
    duration: const Duration(seconds: 3),
    isDismissible: false,
  );
}

showSuccess(String title, String description) async {
  if (Get.isSnackbarOpen == false) {
    getSnackbar_(
      title: title,
      description: description,
      foreground: Colors.white,
      background: const Color.fromARGB(148, 76, 175, 79),
      icon: const Icon(Icons.task_alt_outlined, color: Colors.white),
    );
  }
}

showWarning(String title, String description) async {
  if (Get.isSnackbarOpen) {
    await closeSnackbar();
  }
  if (Get.isSnackbarOpen == false) {
    getSnackbar_(
      title: title,
      description: description,
      background: const Color.fromARGB(148, 255, 153, 0),
      icon: const Icon(Icons.report_problem_outlined, color: Colors.white),
    );
  }
}

showError(String title, String description) async {
  if (Get.isSnackbarOpen) {
    await closeSnackbar();
  }

  if (Get.isSnackbarOpen == false) {
    getSnackbar_(
      title: title,
      description: description,
      background: const Color.fromARGB(148, 244, 67, 54),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}

///get background blur/glass
Widget get bgBlur {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    child: Container(color: Colors.transparent),
  );
}

Future<void> callPhone(String phone) async {
  try {
    final value = phone.trim();
    if (value.isEmpty ||
        !await launchUrl(
          Uri(scheme: 'tel', path: value),
          mode: LaunchMode.externalApplication,
        )) {
      throw const FormatException('Phone unavailable');
    }
  } catch (_) {
    ToastWidget.show(
      title: 'Error'.tr,
      message: 'Cannot call supplier'.tr,
      type: ToastType.error,
    );
  }
}

Future<void> openSupplierMap(
  BuildContext context,
  TextEditingController controller,
) async {
  final route = ModalRoute.of(context);
  try {
    final initialPosition =
        parseCoordinates(controller.text) ?? await _initialMapPosition();

    if (!context.mounted || route?.isCurrent != true) {
      return;
    }

    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialPosition: initialPosition),
      ),
    );

    if (context.mounted && route?.isCurrent == true) {
      applyPickedLocation(controller, picked);
    }
  } catch (e) {
    if (context.mounted && route?.isCurrent == true) {
      ToastWidget.show(
        title: 'Error'.tr,
        message: 'Unable to open location picker'.tr,
        type: ToastType.error,
      );
    }
  }
}

Future<void> openGoogleMap(String value) async {
  try {
    final text = value.trim();
    final coordinate = parseCoordinates(text);
    final uri = coordinate != null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${coordinate.latitude},${coordinate.longitude}',
          )
        : Uri.tryParse(text);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      throw const FormatException('Unsupported map location');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const FormatException('Map unavailable');
    }
  } catch (_) {
    ToastWidget.show(
      title: 'Error'.tr,
      message: 'Cannot open map'.tr,
      type: ToastType.error,
    );
  }
}

Future<void> openEmail(String email) async {
  try {
    final value = email.trim();
    final uri = Uri(
      scheme: 'mailto',
      path: value,
      query: 'subject=Hello&body=I want to contact you',
    );
    if (value.isEmpty || !await launchUrl(uri)) {
      throw const FormatException('Email unavailable');
    }
  } catch (_) {
    ToastWidget.show(
      title: 'Error'.tr,
      message: 'Cannot email supplier'.tr,
      type: ToastType.error,
    );
  }
}

Future<int?> getSystemConfigurationId() async {
  final data = await storage.lastUserLoginRead;

  return data["user"]["system_configuration_id"] as int?;
}

Future<LatLng> _initialMapPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return defaultMapLocation;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return defaultMapLocation;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 10));

    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return defaultMapLocation;
  }
}
