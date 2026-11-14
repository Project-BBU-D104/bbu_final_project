import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/screen/profile/profile_screen.dart';
import 'package:frontend/screen/profile/widget/edit_profile_widget.dart';
import 'package:frontend/screen/profile/widget/change_password_widget.dart';
import 'package:frontend/services/main_service/profile_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:frontend/ui/app_form.dart';

class FakeStorageService implements IStorageService {
  Map<String, dynamic> stored = {};
  int writeCalls = 0;
  int removeCalls = 0;

  void seed() {
    stored = {
      'token': 'tok',
      'token_type': 'bearer',
      'user': {
        'id': 5,
        'name': 'Old Name',
        'email': 'old@example.com',
        'phone': '000',
        'photo': 'old.png',
        'role': {'id': 2, 'name': 'Cashier'},
        'system_configuration_id': 3,
        'is_active': true,
      },
    };
    writeCalls = 0;
    removeCalls = 0;
  }

  @override
  Map<String, dynamic> get lastUserLoginRead => stored;

  @override
  String get currentUserRole => '';

  @override
  bool hasRole(String role) => false;

  @override
  T? readStorage<T>(StorageKey key) => null;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {}

  @override
  Future<void> removeStorage(StorageKey key) async {}

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {}

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  String get appStartUpRead => '';

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {
    stored = Map<String, dynamic>.from(data);
    writeCalls++;
  }

  @override
  Future<void> lastUserLoginRemove() async {
    stored = {};
    removeCalls++;
  }
}

class FakeProfileService implements ProfileService {
  Map<String, dynamic>? updateResult;
  Map<String, dynamic>? passwordResult;
  Exception? failure;
  Completer<void>? updateGate;
  Completer<void>? passwordGate;

  final updateCalls = <Map<String, dynamic>>[];
  final passwordCalls = <Map<String, dynamic>>[];

  @override
  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    updateCalls.add(data);
    if (updateGate != null) await updateGate!.future;
    if (failure != null) throw failure!;
    return updateResult ?? {'id': 5, ...data};
  }

  @override
  Future<dynamic> changePassword(Map<String, dynamic> data) async {
    passwordCalls.add(data);
    if (passwordGate != null) await passwordGate!.future;
    if (failure != null) throw failure!;
    return passwordResult ?? {'message': 'Password changed successfully.'};
  }
}

late FakeStorageService storageFake;

Future<ProfileController> pumpProfile(
  WidgetTester tester,
  FakeProfileService service,
) async {
  final ctr = ProfileController(service: service);
  Get.put<ProfileController>(ctr);
  await tester.pumpWidget(GetMaterialApp(home: ProfileScreen()));
  await tester.pumpAndSettle();
  return ctr;
}

Future<void> openEdit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Edit Profile'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit Profile'));
  await tester.pumpAndSettle();
}

Future<void> openPassword(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Change Password'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Change Password'));
  await tester.pumpAndSettle();
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> closeToasts(WidgetTester tester) async {
  Get.closeAllSnackbars();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    storageFake = FakeStorageService();
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(storageFake);
    }
  });

  setUp(() {
    storageFake.seed();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('update sends only profile fields and preserves the session', (
    tester,
  ) async {
    final service = FakeProfileService()
      ..updateResult = {
        'id': 99,
        'name': 'New Name',
        'email': 'new@example.com',
        'phone': '111',
        'photo': 'new.png',
        'role': {'id': 1, 'name': 'Admin'},
        'is_active': false,
        'system_configuration_id': 999,
      };
    final ctr = await pumpProfile(tester, service);

    await openEdit(tester);
    expect(find.byType(EditProfileWidget), findsOneWidget);
    ctr.nameCtrl.text = '  New Name  ';
    ctr.emailCtrl.text = 'new@example.com';
    ctr.phoneCtrl.text = '111';
    ctr.photoCtrl.text = 'new.png';
    await tester.pump();
    await tapButton(tester, 'Save');

    expect(service.updateCalls, hasLength(1));
    expect(service.updateCalls.single.keys.toSet(), {
      'name',
      'email',
      'phone',
      'photo',
    });
    expect(service.updateCalls.single['name'], 'New Name');

    expect(storageFake.writeCalls, 1);
    final stored = storageFake.stored;
    expect(stored['token'], 'tok');
    expect(stored['token_type'], 'bearer');
    final user = stored['user'] as Map<String, dynamic>;
    expect(user['id'], 5);
    expect(user['name'], 'New Name');
    expect(user['email'], 'new@example.com');
    expect(user['phone'], '111');
    expect(user['photo'], 'new.png');
    expect((user['role'] as Map)['name'], 'Cashier');
    expect(user['system_configuration_id'], 3);
    expect(user['is_active'], true);

    expect(ctr.username.value, 'New Name');
    expect(ctr.email.value, 'new@example.com');
    expect(ctr.phone.value, '111');
    expect(ctr.photo.value, 'new.png');
    expect(find.byType(EditProfileWidget), findsNothing);

    await closeToasts(tester);
  });

  testWidgets('update failure leaves storage and the sheet unchanged', (
    tester,
  ) async {
    final service = FakeProfileService()..failure = Exception('boom');
    final ctr = await pumpProfile(tester, service);
    final before = Map<String, dynamic>.from(storageFake.stored);

    await openEdit(tester);
    ctr.nameCtrl.text = 'New Name';
    ctr.emailCtrl.text = 'new@example.com';
    await tester.pump();
    await tapButton(tester, 'Save');

    expect(service.updateCalls, hasLength(1));
    expect(ctr.nameCtrl.text, 'New Name');
    expect(storageFake.stored, before);
    expect(storageFake.writeCalls, 0);
    expect(ctr.isSaving.value, isFalse);
    expect(find.byType(EditProfileWidget), findsOneWidget);

    await closeToasts(tester);
  });

  testWidgets('password sends only current and new passwords', (tester) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);

    await openPassword(tester);
    expect(find.byType(ChangePasswordWidget), findsOneWidget);
    ctr.currentPasswordCtrl.text = 'oldpass123';
    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass123';
    await tester.pump();
    await tapButton(tester, 'Update Password');

    expect(service.passwordCalls, hasLength(1));
    expect(service.passwordCalls.single, {
      'current_password': 'oldpass123',
      'new_password': 'newpass123',
    });
    expect(find.byType(ChangePasswordWidget), findsNothing);

    await closeToasts(tester);
  });

  testWidgets('wrong current password does not log the user out', (
    tester,
  ) async {
    final service = FakeProfileService()
      ..failure = Exception('Current password is incorrect');
    final ctr = await pumpProfile(tester, service);

    await openPassword(tester);
    ctr.currentPasswordCtrl.text = 'wrong-password';
    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass123';
    await tester.pump();
    await tapButton(tester, 'Update Password');

    expect(storageFake.removeCalls, 0);
    expect(storageFake.stored['token'], 'tok');
    expect(ctr.isSaving.value, isFalse);
    expect(find.byType(ChangePasswordWidget), findsOneWidget);

    await closeToasts(tester);
  });

  testWidgets('two rapid updates make one request', (tester) async {
    final service = FakeProfileService()..updateGate = Completer();
    final ctr = await pumpProfile(tester, service);

    await openEdit(tester);
    ctr.nameCtrl.text = 'New Name';
    ctr.emailCtrl.text = 'new@example.com';
    await tester.pump();

    final ctx = tester.element(find.byType(EditProfileWidget));
    final first = ctr.onUpdateProfile(ctx);
    final second = ctr.onUpdateProfile(ctx);
    service.updateGate!.complete();
    await tester.pump();
    await Future.wait([first, second]);
    await tester.pumpAndSettle();

    expect(service.updateCalls, hasLength(1));
    expect(ctr.isSaving.value, isFalse);

    await closeToasts(tester);
  });
  testWidgets('edit form uses kit sections and prefilled values', (
    tester,
  ) async {
    final ctr = await pumpProfile(tester, FakeProfileService());
    await openEdit(tester);
    expect(find.byType(AppFormSection), findsNWidgets(2));
    expect(find.byType(AppFormField), findsNWidgets(4));
    expect(find.byType(AppFormActions), findsOneWidget);
    expect(ctr.nameCtrl.text, 'Old Name');
    expect(ctr.emailCtrl.text, 'old@example.com');
    expect(ctr.phoneCtrl.text, '000');
    expect(ctr.photoCtrl.text, 'old.png');
  });

  for (final width in [839.0, 840.0]) {
    testWidgets('edit uses adaptive presentation at desktop boundary $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpProfile(tester, FakeProfileService());
      await openEdit(tester);
      expect(
        find.ancestor(
          of: find.byType(EditProfileWidget),
          matching: find.byType(width < 840 ? BottomSheet : Dialog),
        ),
        findsOneWidget,
      );
    });
  }

  for (final control in ['Cancel', 'Close']) {
    testWidgets('edit $control discards only the draft', (tester) async {
      final service = FakeProfileService();
      final ctr = await pumpProfile(tester, service);
      await openEdit(tester);
      ctr.nameCtrl.text = 'Draft';
      final target = control == 'Close'
          ? find.byTooltip('Close')
          : find.widgetWithText(OutlinedButton, 'Cancel');
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      await openEdit(tester);
      expect(ctr.nameCtrl.text, 'Old Name');
      expect(service.updateCalls, isEmpty);
    });
  }

  testWidgets('edit rejects invalid input and focuses the first error', (
    tester,
  ) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);
    await openEdit(tester);
    ctr.nameCtrl.text = '   ';
    ctr.emailCtrl.text = 'invalid';
    await tapButton(tester, 'Save');
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Enter a valid email'), findsOneWidget);
    TextField field(TextEditingController c) => tester
        .widgetList<TextField>(find.byType(TextField))
        .singleWhere((f) => f.controller == c);
    expect(field(ctr.nameCtrl).focusNode!.hasFocus, isTrue);
    ctr.nameCtrl.text = 'Name';
    await tapButton(tester, 'Save');
    expect(field(ctr.emailCtrl).focusNode!.hasFocus, isTrue);
    expect(service.updateCalls, isEmpty);
  });

  testWidgets(
    'edit busy state prevents changes dismissal and duplicate writes',
    (tester) async {
      final service = FakeProfileService()..updateGate = Completer<void>();
      final ctr = await pumpProfile(tester, service);
      await openEdit(tester);
      final context = tester.element(find.byType(EditProfileWidget));
      final first = ctr.onUpdateProfile(context);
      final second = ctr.onUpdateProfile(context);
      await tester.pump();
      expect(service.updateCalls, hasLength(1));
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .every((f) => f.enabled == false),
        isTrue,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.descendant(
                of: find.byType(EditProfileWidget),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Cancel'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
            .onPressed,
        isNull,
      );
      await Navigator.of(context).maybePop();
      await tester.pump();
      expect(find.byType(EditProfileWidget), findsOneWidget);
      service.updateGate!.complete();
      await Future.wait([first, second]);
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileWidget), findsNothing);
      await closeToasts(tester);
    },
  );

  testWidgets('repeated account action opens one form', (tester) async {
    final ctr = await pumpProfile(tester, FakeProfileService());
    final context = tester.element(find.byType(ProfileScreen));
    ctr.openEditProfile(context);
    ctr.openEditProfile(context);
    ctr.openChangePassword(context);
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileWidget), findsOneWidget);
    expect(find.byType(ChangePasswordWidget), findsNothing);
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();
    ctr.openChangePassword(context);
    ctr.openChangePassword(context);
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'password visibility toggles independently and resets on reopen',
    (tester) async {
      final ctr = await pumpProfile(tester, FakeProfileService());
      await openPassword(tester);
      final controllers = [
        ctr.currentPasswordCtrl,
        ctr.newPasswordCtrl,
        ctr.confirmPasswordCtrl,
      ];
      TextField field(int i) => tester
          .widgetList<TextField>(find.byType(TextField))
          .singleWhere((f) => f.controller == controllers[i]);
      for (var i = 0; i < 3; i++) {
        controllers[i].text = 'secret$i';
        expect(field(i).obscureText, isTrue);
        final button = find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AppFormField && w.controller == controllers[i],
          ),
          matching: find.byType(IconButton),
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(field(i).obscureText, isFalse);
        expect(tester.widget<IconButton>(button).tooltip, 'Hide password');
        expect(controllers[i].text, 'secret$i');
        for (var j = i + 1; j < 3; j++) {
          expect(field(j).obscureText, isTrue);
        }
      }
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      await openPassword(tester);
      for (var i = 0; i < 3; i++) {
        expect(field(i).obscureText, isTrue);
        expect(controllers[i].text, isEmpty);
      }
    },
  );

  testWidgets(
    'password validation preserves whitespace and exact confirmation',
    (tester) async {
      final service = FakeProfileService();
      final ctr = await pumpProfile(tester, service);
      await openPassword(tester);
      ctr.currentPasswordCtrl.text = ' oldpass123 ';
      ctr.newPasswordCtrl.text = '  abcdef  ';
      ctr.confirmPasswordCtrl.text = 'abcdef';
      await tapButton(tester, 'Update Password');
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(service.passwordCalls, isEmpty);
      ctr.confirmPasswordCtrl.text = '  abcdef  ';
      await tapButton(tester, 'Update Password');
      expect(service.passwordCalls.single, {
        'current_password': ' oldpass123 ',
        'new_password': '  abcdef  ',
      });
      expect(
        service.passwordCalls.single.containsKey('confirm_password'),
        isFalse,
      );
      await closeToasts(tester);
    },
  );

  testWidgets(
    'password requires current value and eight exact new characters',
    (tester) async {
      final service = FakeProfileService();
      final ctr = await pumpProfile(tester, service);
      await openPassword(tester);
      ctr.newPasswordCtrl.text = '1234567';
      ctr.confirmPasswordCtrl.text = '1234567';
      await tapButton(tester, 'Update Password');
      expect(find.text('Current password is required'), findsOneWidget);
      expect(service.passwordCalls, isEmpty);
      ctr.currentPasswordCtrl.text = 'old';
      ctr.newPasswordCtrl.text = '12345678';
      ctr.confirmPasswordCtrl.text = '12345678';
      await tapButton(tester, 'Update Password');
      expect(service.passwordCalls.single['new_password'], '12345678');
      await closeToasts(tester);
    },
  );

  testWidgets(
    'password editing supports autofill paste and keyboard submission',
    (tester) async {
      final service = FakeProfileService();
      final ctr = await pumpProfile(tester, service);
      await openPassword(tester);
      expect(find.byType(AutofillGroup), findsOneWidget);
      final controllers = [
        ctr.currentPasswordCtrl,
        ctr.newPasswordCtrl,
        ctr.confirmPasswordCtrl,
      ];
      for (var i = 0; i < 3; i++) {
        final target = find.byWidgetPredicate(
          (w) => w is TextField && w.controller == controllers[i],
        );
        final field = tester.widget<TextField>(target);
        expect(field.autofillHints, [
          i == 0 ? AutofillHints.password : AutofillHints.newPassword,
        ]);
        expect(field.autocorrect, isFalse);
        expect(field.enableSuggestions, isFalse);
        expect(field.enableInteractiveSelection, isTrue);
        await tester.ensureVisible(target);
        await tester.enterText(target, i == 0 ? 'oldpass123' : 'newpass123');
        await tester.testTextInput.receiveAction(
          i == 2 ? TextInputAction.done : TextInputAction.next,
        );
        await tester.pumpAndSettle();
        if (i < 2) {
          final next = tester
              .widgetList<TextField>(find.byType(TextField))
              .singleWhere((w) => w.controller == controllers[i + 1]);
          expect(next.focusNode!.hasFocus, isTrue);
        }
      }
      expect(service.passwordCalls, hasLength(1));
      expect(find.byType(ChangePasswordWidget), findsNothing);
      await closeToasts(tester);
    },
  );

  testWidgets('password failure permits retry and preserves the session', (
    tester,
  ) async {
    final service = FakeProfileService()
      ..failure = Exception('incorrect password');
    final ctr = await pumpProfile(tester, service);
    await openPassword(tester);
    ctr.currentPasswordCtrl.text = 'oldpass123';
    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass123';
    await tapButton(tester, 'Update Password');
    expect(ctr.currentPasswordCtrl.text, 'oldpass123');
    expect(ctr.newPasswordCtrl.text, 'newpass123');
    expect(ctr.confirmPasswordCtrl.text, 'newpass123');
    expect(storageFake.stored['token'], 'tok');
    expect((storageFake.stored['user']['role'] as Map)['name'], 'Cashier');
    expect(ctr.isSaving.value, isFalse);
    expect(find.byType(ChangePasswordWidget), findsOneWidget);
    await closeToasts(tester);
    service.failure = null;
    await tapButton(tester, 'Update Password');
    expect(service.passwordCalls, hasLength(2));
    expect(find.byType(ChangePasswordWidget), findsNothing);
    expect(ctr.currentPasswordCtrl.text, isEmpty);
    expect(ctr.newPasswordCtrl.text, isEmpty);
    expect(ctr.confirmPasswordCtrl.text, isEmpty);
    await closeToasts(tester);
  });

  testWidgets('password busy state blocks dismissal and duplicate submission', (
    tester,
  ) async {
    final service = FakeProfileService()..passwordGate = Completer<void>();
    addTearDown(() {
      if (!service.passwordGate!.isCompleted) service.passwordGate!.complete();
    });
    final ctr = await pumpProfile(tester, service);
    await openPassword(tester);
    ctr.currentPasswordCtrl.text = 'oldpass123';
    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass123';
    final context = tester.element(find.byType(ChangePasswordWidget));
    final first = ctr.onChangePassword(context);
    final second = ctr.onChangePassword(context);
    await tester.pump();
    expect(service.passwordCalls, hasLength(1));
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .every((f) => f.enabled == false),
      isTrue,
    );
    final modal = find.byType(ChangePasswordWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(of: modal, matching: find.byType(FilledButton)),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
          .onPressed,
      isNull,
    );
    await Navigator.of(context).maybePop();
    await tester.pump();
    expect(modal, findsOneWidget);
    service.passwordGate!.complete();
    await Future.wait([first, second]);
    await tester.pumpAndSettle();
    expect(modal, findsNothing);
    expect(ctr.isSaving.value, isFalse);
    await closeToasts(tester);
  });

  for (final control in ['Cancel', 'Close', 'Back']) {
    testWidgets('password dismissal via $control clears secrets', (
      tester,
    ) async {
      final ctr = await pumpProfile(tester, FakeProfileService());
      await openPassword(tester);
      ctr.currentPasswordCtrl.text = 'oldpass123';
      ctr.newPasswordCtrl.text = 'newpass123';
      ctr.confirmPasswordCtrl.text = 'newpass123';
      if (control == 'Back') {
        await Navigator.of(
          tester.element(find.byType(ChangePasswordWidget)),
        ).maybePop();
      } else {
        final target = control == 'Close'
            ? find.byTooltip('Close')
            : find.widgetWithText(OutlinedButton, 'Cancel');
        await tester.ensureVisible(target);
        await tester.tap(target);
      }
      await tester.pumpAndSettle();
      expect(ctr.currentPasswordCtrl.text, isEmpty);
      expect(ctr.newPasswordCtrl.text, isEmpty);
      expect(ctr.confirmPasswordCtrl.text, isEmpty);
      await openPassword(tester);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .every((w) => w.obscureText),
        isTrue,
      );
    });
  }
  for (final width in [839.0, 840.0]) {
    for (final password in [false, true]) {
      testWidgets(
        'account opener stays locked through reverse transition $width password=$password',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final ctr = await pumpProfile(tester, FakeProfileService());
          final host = tester.element(find.byType(ProfileScreen));
          Future<void> open() => password
              ? ctr.openChangePassword(host)
              : ctr.openEditProfile(host);
          var completed = false;
          final first = open().whenComplete(() => completed = true);
          await tester.pumpAndSettle();
          final modal = find.byType(
            password ? ChangePasswordWidget : EditProfileWidget,
          );
          Navigator.of(tester.element(modal)).pop();
          await tester.pump(const Duration(milliseconds: 1));
          expect(
            completed,
            isFalse,
            reason: 'the outgoing form still owns its form key',
          );
          open();
          await tester.pump(const Duration(milliseconds: 1));
          expect(modal, findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpAndSettle();
          await first;
          expect(completed, isTrue);
          expect(modal, findsNothing);
          open();
          await tester.pumpAndSettle();
          expect(modal, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
