import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/supplier/location_picker_page.dart';
import 'package:latlong2/latlong.dart';

final Uint8List _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class _MemoryTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_transparentPng);
  }
}

Future<LatLng?> _openPicker(
  WidgetTester tester, {
  required LatLng initialPosition,
  Future<void> Function()? beforeSave,
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

  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  return result;
}

void main() {
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
      },
    );

    expect(result, isNotNull);
    expect(result!.latitude, isNot(initial.latitude));
  });
}
