import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/login_controller.dart';
import 'package:frontend/controllers/landing_controller.dart';
import 'package:frontend/screen/landing.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/auth/login_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'profile_controller_test.dart' show FakeStorageService;

class FakeAuth implements AuthService {
  Object? failure;
  Completer<Map<String, dynamic>>? gate;
  int calls = 0;
  String? name;
  String? password;
  @override
  Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) async {
    calls++;
    this.name = name;
    this.password = password;
    if (failure != null) throw failure!;
    return gate?.future ??
        {'access_token': 'token', 'user': {}, 'token_type': 'bearer'};
  }
}

class FailingStorage extends FakeStorageService {
  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {
    throw StateError('private storage detail');
  }
}

class StartupStorage extends FakeStorageService {
  bool fail = false;
  int removals = 0;
  @override
  Map<String, dynamic> get lastUserLoginRead {
    if (fail) throw StateError('private storage error');
    return stored;
  }

  @override
  String get appStartUpRead => '/saved';
  @override
  Future<void> lastUserLoginRemove() async {
    removals++;
    await super.lastUserLoginRemove();
  }
}

void main() {
  setUpAll(() async {
    for (final family in ['NotoSans', 'NotoSansKhmer']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('fonts/$family.ttf'))).load();
    }
  });
  late FakeAuth auth;
  late LoginController controller;
  late FakeStorageService storage;
  setUp(() {
    Get.testMode = true;
    auth = FakeAuth();
    storage = FakeStorageService();
    controller = LoginController(authService: auth, sessionStorage: storage);
  });
  tearDown(() {
    Get.reset();
  });

  Future<void> showLogin(
    WidgetTester tester, {
    ThemeData? theme,
    Locale? locale,
    double scale = 1,
  }) async {
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: locale ?? const Locale('en', 'US'),
        theme: theme ?? AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: LoginScreen(),
        getPages: [
          GetPage(
            name: '/home',
            page: () => const Scaffold(body: Text('Workspace')),
          ),
        ],
      ),
    );
    await tester.pump();
  }

  testWidgets('empty submit focuses username and corrections revalidate', (
    tester,
  ) async {
    await showLogin(tester);
    expect(controller.usernameController.text, isEmpty);
    expect(controller.passwordController.text, isEmpty);
    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(controller.usernameFocus.hasFocus, isTrue);
    expect(auth.calls, 0);
    expect(find.text('Enter your username'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).first, 'staff');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .autovalidateMode,
      AutovalidateMode.onUserInteraction,
    );
  });

  testWidgets('visibility retains password, selection and focus', (
    tester,
  ) async {
    await showLogin(tester);
    await tester.enterText(find.byType(TextFormField).last, ' secret ');
    controller.passwordController.selection = const TextSelection.collapsed(
      offset: 3,
    );
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(controller.passwordController.text, ' secret ');
    expect(controller.passwordController.selection.baseOffset, 3);
    expect(controller.passwordFocus.hasFocus, isTrue);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets(
    'duplicate submits are guarded and persistence precedes navigation',
    (tester) async {
      auth.gate = Completer();
      await showLogin(tester);
      controller.usernameController.text = ' staff ';
      controller.passwordController.text = ' pass ';
      final first = controller.onLogin();
      await controller.onLogin();
      await tester.pump();
      expect(auth.calls, 1);
      expect(auth.name, 'staff');
      expect(auth.password, ' pass ');
      expect(find.text('Signing in…'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      auth.gate!.complete({
        'access_token': 'token',
        'user': {},
        'token_type': 'bearer',
      });
      await first;
      await tester.pumpAndSettle();
      expect(storage.writeCalls, 1);
      expect(find.text('Workspace'), findsOneWidget);
    },
  );

  for (final failure in [
    ApiException(401, 'private'),
    http.ClientException('private'),
    TimeoutException('private'),
    StateError('private'),
  ]) {
    testWidgets('safe persistent error for ${failure.runtimeType}', (
      tester,
    ) async {
      auth.failure = failure;
      await showLogin(tester);
      controller.usernameController.text = 'staff';
      controller.passwordController.text = 'secret';
      await controller.onLogin();
      await tester.pump();
      expect(find.text(controller.errorMessage.value), findsOneWidget);
      expect(
        controller.errorMessage.value,
        failure is ApiException
            ? 'Username or password is incorrect.'
            : failure is http.ClientException || failure is TimeoutException
            ? 'Unable to connect. Check your connection and try again.'
            : 'Unable to sign in. Please try again.',
      );
      expect(controller.errorMessage.value, isNot(contains('private')));
      expect(controller.passwordController.text, 'secret');
      expect(controller.isLoading.value, isFalse);
      expect(storage.writeCalls, 0);
    });
  }

  testWidgets('persistence failure stays on login with safe error', (
    tester,
  ) async {
    controller = LoginController(
      authService: auth,
      sessionStorage: FailingStorage(),
    );
    await showLogin(tester);
    controller.usernameController.text = 'staff';
    controller.passwordController.text = 'secret';
    await controller.onLogin();
    await tester.pump();
    expect(find.text('Unable to sign in. Please try again.'), findsOneWidget);
    expect(find.text('Workspace'), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final locale in [const Locale('en', 'US'), const Locale('km', 'KH')]) {
      testWidgets(
        'responsive ${dark ? 'dark' : 'light'} $locale at 200% text',
        (tester) async {
          addTearDown(() => tester.view.resetPhysicalSize());
          addTearDown(() => tester.view.resetDevicePixelRatio());
          tester.view.devicePixelRatio = 1;
          await showLogin(
            tester,
            theme: dark
                ? AppTheme.dark(
                    fontFamily: locale.languageCode == 'km'
                        ? 'NotoSansKhmer'
                        : 'NotoSans',
                  )
                : AppTheme.light(
                    fontFamily: locale.languageCode == 'km'
                        ? 'NotoSansKhmer'
                        : 'NotoSans',
                  ),
            locale: locale,
            scale: 2,
          );
          for (final size in [
            const Size(320, 640),
            const Size(375, 667),
            const Size(768, 1024),
            const Size(1024, 768),
            const Size(1440, 900),
            const Size(640, 320),
          ]) {
            tester.view.physicalSize = size;
            await tester.pump();
            expect(tester.takeException(), isNull, reason: '$size');
            await tester.ensureVisible(find.byType(FilledButton));
            await tester.pump();
            expect(tester.takeException(), isNull);
          }
          tester.view.viewInsets = const FakeViewPadding(bottom: 180);
          addTearDown(tester.view.resetViewInsets);
          await tester.pump();
          await tester.ensureVisible(find.byType(FilledButton));
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final valid in [false, true]) {
    testWidgets('startup routes a ${valid ? 'valid' : 'stale'} session', (
      tester,
    ) async {
      final startupStorage = StartupStorage();
      final exp =
          DateTime.now()
              .add(Duration(hours: valid ? 1 : -1))
              .millisecondsSinceEpoch ~/
          1000;
      final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': exp})));
      startupStorage.stored = {'token': 'header.$payload.signature'};
      final startup = LandingController(sessionStorage: startupStorage);
      Get.put(startup);
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LandingScreen(),
          getPages: [
            GetPage(
              name: '/saved',
              page: () => const Scaffold(body: Text('Saved destination')),
            ),
            GetPage(
              name: '/login',
              page: () => const Scaffold(body: Text('Login destination')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(valid ? 'Saved destination' : 'Login destination'),
        findsOneWidget,
      );
      expect(startupStorage.removals, valid ? 0 : 1);
      await tester.pump(const Duration(seconds: 2));
    });
  }

  testWidgets('startup failure offers retry without clearing stored data', (
    tester,
  ) async {
    final startupStorage = StartupStorage()..fail = true;
    final startup = LandingController(sessionStorage: startupStorage);
    Get.put(startup);
    await tester.pumpWidget(
      GetMaterialApp(
        home: const LandingScreen(),
        getPages: [
          GetPage(
            name: '/login',
            page: () => const Scaffold(body: Text('Login destination')),
          ),
        ],
      ),
    );
    await tester.pump();
    expect(find.text("We couldn't open your workspace"), findsOneWidget);
    expect(startupStorage.removals, 0);
    startupStorage.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  test('auth semantic colors meet normal-text contrast in both themes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final c = theme.colorScheme;
      for (final pair in [
        (c.primary, c.onPrimary),
        (c.primaryContainer, c.onPrimaryContainer),
        (c.surface, c.onSurface),
        (c.surface, c.onSurfaceVariant),
        (c.errorContainer, c.onErrorContainer),
      ]) {
        final a = pair.$1.computeLuminance();
        final b = pair.$2.computeLuminance();
        expect(
          (math.max(a, b) + .05) / (math.min(a, b) + .05),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });
}
