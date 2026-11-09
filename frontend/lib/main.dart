import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_background.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'localization/app_translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/gestures.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await _initConfig();

  await _initStorage();

  await GetStorage.init();
  setupLocator();

  Get.put(LanguageController());
  Get.put(ThemeController());

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const MyApp(),
  //   ),
  // );
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _route = ValueNotifier<String>(AppRoutes.landing);

  void _onRouting(Routing? routing) {
    final current = routing?.current;
    if (current == null || current.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _route.value = current;
    });
  }

  @override
  void dispose() {
    _route.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,

        useInheritedMediaQuery: true,
        locale: DevicePreview.isEnabled(context)
            ? DevicePreview.locale(context)
            : languageController.locale.value,
        fallbackLocale: const Locale("en", "US"),

        scrollBehavior: _CustomScrollBehavior(),
        initialRoute: AppRoutes.landing,
        getPages: AppPages.pages,
        routingCallback: _onRouting,

        translations: AppTranslation(),

        transitionDuration: const Duration(milliseconds: 0),
        defaultTransition: Transition.noTransition,
        // Apply the bundled font for the active language; the Obx rebuilds on locale change.
        theme: AppTheme.light(fontFamily: languageController.fontFamily),
        darkTheme: AppTheme.dark(fontFamily: languageController.fontFamily),
        themeMode: themeController.isDark.value
            ? ThemeMode.dark
            : ThemeMode.light,

        builder: (context, child) {
          return DevicePreview.appBuilder(
            context,
            Stack(
              children: [
                const AppBackground(child: SizedBox.expand()),
                ValueListenableBuilder<String>(
                  valueListenable: _route,
                  child: child ?? const SizedBox(),
                  builder: (context, route, navigator) =>
                      DesktopAppShell(route: route, child: navigator!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
