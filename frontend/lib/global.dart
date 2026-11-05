import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/services/telegram_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/screen/supplier/location_picker_page.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:latlong2/latlong.dart';


//// Variables
// final storage = GetStorage(".appsettings");
// final app = locator<IAppService>();

final storage = locator<IStorageService>();

final telegram = locator<TelegramService>();

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
    duration: const Duration(
      seconds: 3,
    ),
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
      icon: const Icon(
        Icons.report_problem_outlined,
        color: Colors.white,
      ),
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
    child: Container(
      color: Colors.transparent,
    ),
  );
}
 
Future<void> callPhone(String phone) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else if (Platform.isWindows) {
    // Windows: open browser/search or copy number
    // print("Phone call not supported on Windows: $phone");
  }
}

Future<void> openSupplierMap(
  BuildContext context,
  TextEditingController controller,
) async {
  try {
    final initialPosition =
        parseCoordinates(controller.text) ?? await _initialMapPosition();

    if (!context.mounted) {
      return;
    }

    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialPosition: initialPosition),
      ),
    );

    applyPickedLocation(controller, picked);
  } catch (e) {
    showError("Error", e.toString());
  }
}

Future<void> openGoogleMap(String value) async {
  try {
    String url = value;

    // Check if value is latitude,longitude
    final coordinate = RegExp(
      r'^-?\d+(\.\d+)?,\s*-?\d+(\.\d+)?$',
    );

    if (coordinate.hasMatch(value)) {
      url = "https://www.google.com/maps/search/?api=1&query=$value";
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showError(
        "Error",
        "Cannot open map",
      );
    }
  } catch (e) {
    showError(
      "Error",
      e.toString(),
    );
  }
}

Future<void> openEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=Hello&body=I want to contact you',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
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
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).timeout(const Duration(seconds: 10));

    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return defaultMapLocation;
  }
}