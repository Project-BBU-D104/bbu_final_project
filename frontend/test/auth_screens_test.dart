import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/login_controller.dart';
import 'package:frontend/controllers/landing_controller.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/constants/enum.dart';
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

class AuthPreferencesStorage extends FakeStorageService {
  final preferences = <StorageKey, dynamic>{};
  @override
  T? readStorage<T>(StorageKey key) => preferences[key] as T?;
  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {
    preferences[key] = value;
  }
}

class AuthLanguage extends GetxController implements LanguageController {
  @override
  final locale = const Locale('en', 'US').obs;
  @override
  String get fontFamily =>
      locale.value.languageCode == 'km' ? 'NotoSansKhmer' : 'NotoSans';
  @override
  void changeLanguage(String code) {
    locale.value = code == 'km'
        ? const Locale('km', 'KH')
        : const Locale('en', 'US');
    Get.updateLocale(locale.value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  late AuthPreferencesStorage storage;
  setUp(() {
    Get.testMode = true;
    auth = FakeAuth();
    storage = AuthPreferencesStorage();
    controller = LoginController(authService: auth, sessionStorage: storage);
    Get.put<LanguageController>(AuthLanguage());
    Get.put(ThemeController(storageService: storage));
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
      Obx(() {
        final language = Get.find<LanguageController>();
        final activeLocale = language.locale.value;
        final dark = Get.find<ThemeController>().isDark.value;
        return GetMaterialApp(
          translations: AppTranslation(),
          locale: locale ?? activeLocale,
          theme: theme ?? AppTheme.light(fontFamily: language.fontFamily),
          darkTheme: AppTheme.dark(fontFamily: language.fontFamily),
          themeMode: theme != null
              ? ThemeMode.light
              : dark
              ? ThemeMode.dark
              : ThemeMode.light,
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
        );
      }),
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
      expect(
        tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .every((field) => field.enabled == false),
        isTrue,
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

  testWidgets(
    'theme preference works before sign-in without losing credentials',
    (tester) async {
      await showLogin(tester);
      controller.usernameController.text = 'staff';
      controller.passwordController.text = ' secret ';
      await tester.tap(find.byTooltip('Switch to dark mode'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(LoginScreen))).brightness,
        Brightness.dark,
      );
      expect(storage.preferences[StorageKey.darkMode], isTrue);
      expect(controller.usernameController.text, 'staff');
      expect(controller.passwordController.text, ' secret ');
      await tester.tap(find.byTooltip('Switch to light mode'));
      await tester.pumpAndSettle();
      expect(storage.preferences[StorageKey.darkMode], isFalse);
      expect(auth.calls, 0);
    },
  );

  testWidgets('language can change before sign-in without losing credentials', (
    tester,
  ) async {
    await showLogin(tester);
    controller.usernameController.text = 'staff';
    controller.passwordController.text = ' secret ';
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('ខ្មែរ'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(Get.locale?.languageCode, 'km');
    expect(find.text('ភ្លេចពាក្យសម្ងាត់?'), findsOneWidget);
    expect(controller.usernameController.text, 'staff');
    expect(controller.passwordController.text, ' secret ');
    expect(auth.calls, 0);
  });

  testWidgets('password recovery explains the supported administrator flow', (
    tester,
  ) async {
    await showLogin(tester);
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Password recovery'), findsOneWidget);
    expect(
      find.text(
        'Contact your administrator to reset your password in User Management.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(auth.calls, 0);
  });

  testWidgets(
    'autofill hints and keyboard submit commit credentials only on success',
    (tester) async {
      await showLogin(tester);
      await tester.ensureVisible(find.byType(TextFormField).first);
      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();
      final usernameAutofill =
          tester.testTextInput.setClientArgs!['autofill'] as Map;
      expect(usernameAutofill['hints'], contains(AutofillHints.username));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(text: 'saved_user'),
      );
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(controller.passwordFocus.hasFocus, isTrue);
      final passwordConfig = tester.testTextInput.setClientArgs!;
      expect(
        (passwordConfig['autofill'] as Map)['hints'],
        contains(AutofillHints.password),
      );
      expect(passwordConfig['obscureText'], isTrue);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(text: ' saved_password '),
      );
      auth.failure = ApiException(401, 'private');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(auth.calls, 1);
      expect(auth.password, ' saved_password ');
      expect(
        tester.testTextInput.log.where(
          (call) =>
              call.method == 'TextInput.finishAutofillContext' &&
              call.arguments == true,
        ),
        isEmpty,
      );
      expect(controller.passwordController.text, ' saved_password ');
      auth.failure = null;
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Workspace'), findsOneWidget);
      expect(
        tester.testTextInput.log.where(
          (call) =>
              call.method == 'TextInput.finishAutofillContext' &&
              call.arguments == true,
        ),
        hasLength(1),
      );
    },
  );

  testWidgets('password accepts paste without altering whitespace', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return {'text': ' pasted secret '};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await showLogin(tester);
    await tester.ensureVisible(find.byType(TextFormField).last);
    await tester.tap(find.byType(TextFormField).last);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(controller.passwordController.text, ' pasted secret ');
    expect(auth.calls, 0);
  });

  testWidgets('keyboard traversal operates password visibility and recovery', (
    tester,
  ) async {
    await showLogin(tester);
    await tester.ensureVisible(find.byType(TextFormField).last);
    await tester.tap(find.byType(TextFormField).last);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(controller.obscurePassword.value, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(auth.calls, 0);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'auth controls have accessible names and touch targets in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();
        await showLogin(
          tester,
          theme: dark ? AppTheme.dark() : AppTheme.light(),
        );
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        final visibility = tester
            .getSemantics(find.byTooltip('Show password'))
            .getSemanticsData();
        expect(visibility.tooltip, 'Show password');
        expect(visibility.flagsCollection.isButton, isTrue);
        expect(visibility.flagsCollection.isSelected, ui.Tristate.isFalse);
        expect(
          tester
              .getSemantics(find.text('Welcome back'))
              .getSemanticsData()
              .flagsCollection
              .isHeader,
          isTrue,
        );
        expect(find.bySemanticsLabel('Forgot password?'), findsOneWidget);
        expect(find.bySemanticsLabel('Language'), findsOneWidget);
        semantics.dispose();
      },
    );
  }

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
