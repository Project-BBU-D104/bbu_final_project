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
  final stored = <String, dynamic>{
    'token': 'tok',
    'user': {
      'id': 5,
      'name': 'Old Name',
      'email': 'old@example.com',
      'phone': '000',
      'photo': '',
      'role': {'id': 2, 'name': 'Cashier'},
    },
  };

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
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}
}

class FakeProfileService implements ProfileService {
  final updateCalls = <Map<String, dynamic>>[];
  final passwordCalls = <Map<String, dynamic>>[];

  @override
  Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    updateCalls.add(data);
    return {'id': 5, ...data};
  }

  @override
  Future<dynamic> changePassword(Map<String, dynamic> data) async {
    passwordCalls.add(data);
    return {'message': 'Password changed successfully.'};
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

Future<void> openSheet(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
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

  tearDown(() {
    Get.reset();
  });

  testWidgets('edit sheet replaces the placeholder and opens from the screen',
      (tester) async {
    final service = FakeProfileService();
    await pumpProfile(tester, service);

    await openSheet(tester, 'Edit Profile');

    expect(find.byType(EditProfileWidget), findsOneWidget);
    expect(find.text('Edit Profile Widget'), findsNothing);
  });

  testWidgets('blank name and invalid email never call the service',
      (tester) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);

    await openSheet(tester, 'Edit Profile');
    ctr.emailCtrl.text = 'valid@example.com';
    ctr.nameCtrl.text = '   ';
    await tester.pump();
    await tapButton(tester, 'Save');
    expect(service.updateCalls, isEmpty);

    ctr.nameCtrl.text = 'Valid Name';
    ctr.emailCtrl.text = 'not-an-email';
    await tester.pump();
    await tapButton(tester, 'Save');
    expect(service.updateCalls, isEmpty);
    expect(find.byType(EditProfileWidget), findsOneWidget);
  });

  testWidgets('valid edit closes the sheet on success', (tester) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);

    await openSheet(tester, 'Edit Profile');
    ctr.nameCtrl.text = 'Valid Name';
    ctr.emailCtrl.text = 'valid@example.com';
    ctr.phoneCtrl.text = '012';
    ctr.photoCtrl.text = '';
    await tester.pump();
    await tapButton(tester, 'Save');

    expect(service.updateCalls, hasLength(1));
    expect(find.byType(EditProfileWidget), findsNothing);

    await closeToasts(tester);
  });

  testWidgets('short password and mismatched confirmation never call the service',
      (tester) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);

    await openSheet(tester, 'Change Password');
    expect(find.byType(ChangePasswordWidget), findsOneWidget);
    ctr.currentPasswordCtrl.text = 'oldpass123';
    ctr.newPasswordCtrl.text = 'short';
    ctr.confirmPasswordCtrl.text = 'short';
    await tester.pump();
    await tapButton(tester, 'Update Password');
    expect(service.passwordCalls, isEmpty);

    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass12';
    await tester.pump();
    await tapButton(tester, 'Update Password');
    expect(service.passwordCalls, isEmpty);
    expect(find.byType(ChangePasswordWidget), findsOneWidget);
  });

  testWidgets('valid password change closes the sheet', (tester) async {
    final service = FakeProfileService();
    final ctr = await pumpProfile(tester, service);

    await openSheet(tester, 'Change Password');
    ctr.currentPasswordCtrl.text = 'oldpass123';
    ctr.newPasswordCtrl.text = 'newpass123';
    ctr.confirmPasswordCtrl.text = 'newpass123';
    await tester.pump();
    await tapButton(tester, 'Update Password');

    expect(service.passwordCalls, hasLength(1));
    expect(find.byType(ChangePasswordWidget), findsNothing);

    await closeToasts(tester);
  });
}
