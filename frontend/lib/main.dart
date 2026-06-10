import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'localization/app_translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/gestures.dart'; 

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  await _initConfig();
  runApp(const MyApp());
}

Future<void> _initConfig() async {
  await dotenv.load(fileName: "assets/.env");
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
