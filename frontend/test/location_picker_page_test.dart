import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/supplier/location_picker_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:frontend/utils/location_utils.dart';
import 'supplier_test_support.dart';

final Uint8List _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class _MemoryTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_transparentPng);
  }
}

class _FailingTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(Uint8List(0));
}

Future<LatLng?> _openPicker(
  WidgetTester tester, {
  required LatLng initialPosition,
  Future<void> Function()? beforeSave,
  bool cancel = false,
}) async {
  LatLng? result;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<LatLng>(
              MaterialPageRoute(
                builder: (_) => LocationPickerPage(
                  initialPosition: initialPosition,
                  tileProvider: _MemoryTileProvider(),
                ),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  if (beforeSave != null) {
    await beforeSave();
  }

  if (!cancel) {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  return result;
}

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);
  testWidgets('picker remains operable without tiles in Khmer and large text', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      await pumpSupplierHost(
        tester,
        home: LocationPickerPage(
          initialPosition: defaultMapLocation,
          tileProvider: _FailingTileProvider(),
        ),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
      await tester.ensureVisible(find.text('Save'.tr));
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('typed coordinates save and map taps synchronize the field', (
    tester,
  ) async {
    final result = await _openPicker(
      tester,
      initialPosition: const LatLng(11.5564, 104.9282),
      beforeSave: () async {
        await tester.enterText(find.byType(TextFormField), '-33.8688,151.2093');
        await tester.pumpAndSettle();
      },
    );
    expect(result?.latitude, -33.8688);
    expect(result?.longitude, 151.2093);
  });
  testWidgets('invalid coordinates cannot save', (tester) async {
    final result = await _openPicker(
      tester,
      initialPosition: const LatLng(11.5564, 104.9282),
      beforeSave: () async {
        for (final text in ['91,0', '0,181', '', 'abc,def']) {
          await tester.enterText(find.byType(TextFormField), text);
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          expect(
            find.text('Enter valid latitude,longitude coordinates.'),
            findsOneWidget,
          );
          expect(find.byType(LocationPickerPage), findsOneWidget);
        }
        await tester.enterText(find.byType(TextFormField), '11,104');
      },
    );
    expect(result?.latitude, 11);
  });
  testWidgets('cancel returns no coordinates', (tester) async {
    final result = await _openPicker(
      tester,
      initialPosition: const LatLng(11.5564, 104.9282),
      beforeSave: () async {
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
      cancel: true,
    );
    expect(result, isNull);
  });
  testWidgets('Save closes the picker and returns the selected position', (
    tester,
  ) async {
    const initial = LatLng(11.5564, 104.9282);

    final result = await _openPicker(tester, initialPosition: initial);

    expect(result, isNotNull);
    expect(result!.latitude, initial.latitude);
    expect(result.longitude, initial.longitude);
  });

  testWidgets('tapping the map selects a different position', (tester) async {
    const initial = LatLng(11.5564, 104.9282);

    final result = await _openPicker(
      tester,
      initialPosition: initial,
      beforeSave: () async {
        final mapCenter = tester.getCenter(find.byType(FlutterMap));
        await tester.tapAt(mapCenter + const Offset(100, -100));
        // flutter_map waits for the double-tap window before reporting a tap.
        await tester.pump(const Duration(milliseconds: 400));
        final coordinates = tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text;
        expect(parseCoordinates(coordinates), isNotNull);
      },
    );

    expect(result, isNotNull);
    expect(result!.latitude, isNot(initial.latitude));
  });
}
