import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';

//// Variables
// final storage = GetStorage(".appsettings");
// final app = locator<IAppService>();
// final storage = locator<IStorageService>();

String appName = "ePOS App";
String deviceID = "";
String appVersion = "0.0.0";

// variable Rx
final licenseInfo = <String, dynamic>{}.obs;
final showLicense = false.obs;
//end variable Rx

String serverUrl = "";

/// get value from env setting
// dynamic env(ENV key) {
//   final vkey = key.toString().split('.').last; // Output: active
//   return dotenv.env[toUpperSnakeCase(vkey)];
// }

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

/// [server_url]/api/method/
String get apiBaseUrl {
  return "$serverUrl/api/method/";
}

///[base-url]api/method/epos_app.api.
String get apiUrl {
  return "$serverUrl/api/method/epos_app.api.";
}

/// [server_url]/api/resource/
String get apiResourceUrl {
  return "$serverUrl/api/resource/";
}

////Methods
//* all method *//

// Future<void> initApp() async {
//   final info = await PackageInfo.fromPlatform();
//   deviceID = await app.getDeviceId;
//   appVersion = info.version;
//   showLicense(false);

//   if (kDebugMode) {
//     print(info);
//   }
//   // appVersion = "${info.version}+${info.buildNumber}";
// }

/// AES Decrypt method
// String eDecrypted(String encrypted) {
//   return onDecrypted(encrypted);
// }

/// AES Encrypt method
// String eEcrypted(String plainText) {
//   return onEcrypted(plainText);
// }

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

/// get current language
// Locale get getCurrentLanguage {
//   final key = storage.readStorage(StorageKey.currentLanguage);
//   var lang = Locale('en', "US");
//   switch (key) {
//     case "km":
//       lang = Locale('km', "KHM");
//       break;
//     default:
//       break;
//   }
//   return lang;
// }

///workspace
// SystemMode get currentSystemMode {
//   var val = storage.readStorage<String>(StorageKey.systemMode) ?? "light";
//   SystemMode mode = SystemMode.light;
//   switch (val) {
//     case "light":
//       mode = SystemMode.light;
//       break;
//     case "dark":
//       mode = SystemMode.dark;
//       break;
//     default:
//       mode = SystemMode.system;
//       break;
//   }
//   return mode;
// }

// MaterialColor get background {
//   Color light = HexColor.fromHex("#ffffff");
//   Color dark = HexColor.fromHex("#101010");
//   switch (currentSystemMode) {
//     case SystemMode.dark:
//       return createMaterialColor(dark);
//     case SystemMode.light:
//       return createMaterialColor(light);

//     default:
//       final brightness =
//           WidgetsBinding.instance.platformDispatcher.platformBrightness;
//       if (brightness == Brightness.dark) {
//         return createMaterialColor(dark);
//       } else {
//         return createMaterialColor(light);
//       }
//   }
// }

///get backgroud box decoration
// BoxDecoration get bgBoxDecoration {
//   return BoxDecoration(
//     color: background,
//     image: DecorationImage(
//       image: AssetImage(backgroundPath),
//       fit: BoxFit.fill,
//     ),
//   );
// }

///get background blur/glass
Widget get bgBlur {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
    child: Container(
      color: Colors.transparent,
    ),
  );
}

///get logo no background
// Widget loadLogoNoBg([double? width, double? height]) {
//   return Image.asset(
//     logoNoBackgroundPath,
//     width: width ?? 70,
//     height: height ?? 70,
//     fit: BoxFit.cover,
//   );
// }
