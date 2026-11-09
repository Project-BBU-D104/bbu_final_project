import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/global.dart';
import 'package:frontend/screen/supplier/location_picker_page.dart';
// Test the installed plugins through their platform interfaces without adding dependencies.
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

class FakeLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  final urls = <String>[];
  bool result = true, throws = false;
  @override
  Future<bool> canLaunch(String url) async => true;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    if (throws) throw Exception('unavailable');
    return result;
  }
}

class FakeLocation extends GeolocatorPlatform {
  bool enabled = false;
  LocationPermission permission = LocationPermission.deniedForever;
  int checks = 0;
  Completer<Position>? position;
  @override
  Future<bool> isLocationServiceEnabled() async {
    checks++;
    return enabled;
  }

  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async => permission;
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      position!.future;
}

void main() {
  late FakeLauncher launcher;
  late UrlLauncherPlatform originalLauncher;
  late GeolocatorPlatform originalLocation;
  setUp(() {
    setUpSupplierTests();
    originalLauncher = UrlLauncherPlatform.instance;
    originalLocation = GeolocatorPlatform.instance;
    launcher = FakeLauncher();
    UrlLauncherPlatform.instance = launcher;
  });
  tearDown(() {
    UrlLauncherPlatform.instance = originalLauncher;
    GeolocatorPlatform.instance = originalLocation;
    Get.reset();
  });
  testWidgets('map launch failure has Khmer feedback', (tester) async {
    await pumpSupplierHost(
      tester,
      home: const Scaffold(),
      locale: const Locale('km', 'KH'),
    );
    await openGoogleMap('javascript:alert(1)');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('មិនអាចបើកផែនទីបានទេ'), findsOneWidget);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
  testWidgets(
    'location lookup completing during sheet dismissal never opens a picker',
    (tester) async {
      final location = FakeLocation()
        ..enabled = true
        ..permission = LocationPermission.whileInUse
        ..position = Completer<Position>();
      GeolocatorPlatform.instance = location;
      final text = TextEditingController();
      addTearDown(text.dispose);
      late BuildContext host, sheet;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              host = context;
              return const Scaffold();
            },
          ),
        ),
      );
      showModalBottomSheet<void>(
        context: host,
        builder: (context) {
          sheet = context;
          return const SizedBox(height: 200);
        },
      );
      await tester.pumpAndSettle();
      final pending = openSupplierMap(sheet, text);
      await tester.pump();
      Navigator.of(sheet).pop();
      expect(sheet.mounted, true);
      location.position!.completeError(Exception('location unavailable'));
      await tester.pump();
      await tester.pump();
      final opened = find.byType(LocationPickerPage).evaluate().length;
      if (opened > 0) Navigator.of(host).pop();
      await tester.pumpAndSettle();
      await pending;
      expect(opened, 0);
      expect(text.text, isEmpty);
    },
  );
  testWidgets('contact launch handles supported and rejected values', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await callPhone('012345678');
    await openEmail('supplier@example.com');
    await openGoogleMap('11.5564,104.9282');
    await openGoogleMap('https://maps.google.com/?q=11,104');
    expect(launcher.urls.length, 4);
    expect(launcher.urls[0], 'tel:012345678');
    expect(Uri.parse(launcher.urls[1]).scheme, 'mailto');
    expect(
      launcher.urls[2],
      'https://www.google.com/maps/search/?api=1&query=11.5564,104.9282',
    );
    expect(launcher.urls[3], 'https://maps.google.com/?q=11,104');
    for (final bad in [
      '',
      'javascript:alert(1)',
      'file:///tmp/example',
      '91,0',
    ]) {
      await openGoogleMap(bad);
      await tester.pumpAndSettle();
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
    }
    expect(launcher.urls.length, 4);
  });
  testWidgets('false launch results and exceptions show feedback', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    launcher.result = false;
    await callPhone('012345678');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Cannot call supplier'), findsOneWidget);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    launcher.throws = true;
    await openEmail('supplier@example.com');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Cannot email supplier'), findsOneWidget);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
  for (final mode in ['saved', 'disabled', 'denied', 'timeout']) {
    testWidgets(
      '$mode location uses saved or fallback center and cancel preserves draft',
      (tester) async {
        final location = FakeLocation()
          ..enabled = mode == 'denied' || mode == 'timeout';
        if (mode == 'timeout') {
          location.permission = LocationPermission.whileInUse;
          location.position = Completer<Position>();
        }
        GeolocatorPlatform.instance = location;
        final text = TextEditingController(
          text: mode == 'saved'
              ? '-33.8688,151.2093'
              : 'https://maps.google.com/',
        );
        addTearDown(text.dispose);
        final before = text.text;
        late BuildContext host;
        await tester.pumpWidget(
          GetMaterialApp(
            home: Builder(
              builder: (context) {
                host = context;
                return const Scaffold();
              },
            ),
          ),
        );
        final future = openSupplierMap(host, text);
        await tester.pump();
        if (mode == 'timeout') {
          await tester.pump(const Duration(seconds: 11));
        }
        await tester.pump(const Duration(milliseconds: 400));
        final picker = tester.widget<LocationPickerPage>(
          find.byType(LocationPickerPage),
        );
        expect(
          picker.initialPosition.latitude,
          mode == 'saved' ? -33.8688 : 11.5564,
        );
        expect(
          picker.initialPosition.longitude,
          mode == 'saved' ? 151.2093 : 104.9282,
        );
        if (mode == 'saved') expect(location.checks, 0);
        Navigator.of(host).pop();
        await tester.pumpAndSettle();
        await future;
        expect(text.text, before);
        if (location.position != null) {
          location.position!.completeError(Exception('late'));
        }
        await tester.pump();
      },
    );
  }
  testWidgets(
    'unmounted host never changes disposed draft after location wait',
    (tester) async {
      final location = FakeLocation()
        ..enabled = true
        ..permission = LocationPermission.whileInUse
        ..position = Completer<Position>();
      GeolocatorPlatform.instance = location;
      final text = TextEditingController();
      late BuildContext host;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) {
              host = context;
              return const Scaffold();
            },
          ),
        ),
      );
      final future = openSupplierMap(host, text);
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      text.dispose();
      await tester.pump(const Duration(seconds: 11));
      await future;
      expect(tester.takeException(), isNull);
      location.position!.completeError(Exception('late'));
      await tester.pump();
    },
  );
}
