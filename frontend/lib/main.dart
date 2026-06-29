import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'localization/app_translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/gestures.dart'; 
import 'package:get_storage/get_storage.dart';

Future<void> main() async {

  await dotenv.load(fileName: "assets/.env");
  await _initConfig();


  _initStorage();
  
  await GetStorage.init();
 setupLocator();

  runApp(const MyApp());

}

Future<void> _initConfig() async {
  await dotenv.load(fileName: "assets/.env");
}

Future<void> _initStorage() async {
  const boxName = ".appsettings";
  if (kIsWeb) {
    await GetStorage.init(boxName);
  } else if (Platform.isWindows) {
    final dir = "${Directory.current.path}\\.config";
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    await GetStorage(".appsettings", dir).initStorage;
  } else {
    await GetStorage.init(boxName);
  }
}

class _CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: _CustomScrollBehavior(),
      initialRoute: AppRoutes.landing,
      getPages: AppPages.pages,

      // translate
      translations: AppTranslation(),
      locale: const Locale('km', 'KHM'), // default
      fallbackLocale: const Locale('km', 'KHM'), 
    );
  }
}
