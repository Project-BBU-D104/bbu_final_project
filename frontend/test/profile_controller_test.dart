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

  final updateCalls = <Map<String, dynamic>>[];
  final passwordCalls = <Map<String, dynamic>>[];

  @override
  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    if (updateGate != null) await updateGate!.future;
    if (failure != null) throw failure!;
    updateCalls.add(data);
    return updateResult ?? {'id': 5, ...data};
  }

  @override
  Future<dynamic> changePassword(Map<String, dynamic> data) async {
    if (failure != null) throw failure!;
    passwordCalls.add(data);
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
  final finder = find.widgetWithText(ElevatedButton, label);
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

  testWidgets('update sends only profile fields and preserves the session',
      (tester) async {
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

  testWidgets('update failure leaves storage and the sheet unchanged',
      (tester) async {
    final service = FakeProfileService()..failure = Exception('boom');
    final ctr = await pumpProfile(tester, service);
    final before = Map<String, dynamic>.from(storageFake.stored);

    await openEdit(tester);
    ctr.nameCtrl.text = 'New Name';
    ctr.emailCtrl.text = 'new@example.com';
    await tester.pump();
    await tapButton(tester, 'Save');

    expect(service.updateCalls, isEmpty);
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

  testWidgets('wrong current password does not log the user out',
      (tester) async {
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
}
