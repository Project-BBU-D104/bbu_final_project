import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('formatCoordinates', () {
    test('writes latitude and longitude with six decimals and no spaces', () {
      expect(
        formatCoordinates(const LatLng(11.5564, 104.9282)),
        '11.556400,104.928200',
      );
    });

    test('keeps negative coordinates', () {
      expect(
        formatCoordinates(const LatLng(-33.8688, 151.2093)),
        '-33.868800,151.209300',
      );
    });
  });

  group('parseCoordinates', () {
    test('reads coordinates with or without spaces', () {
      final plain = parseCoordinates('11.5564,104.9282');
      expect(plain?.latitude, 11.5564);
      expect(plain?.longitude, 104.9282);

      final padded = parseCoordinates(' 11.5564 , 104.9282 ');
      expect(padded?.latitude, 11.5564);
      expect(padded?.longitude, 104.9282);
    });

    test('round trips a formatted value', () {
      const original = LatLng(11.5564, 104.9282);
      final parsed = parseCoordinates(formatCoordinates(original));

      expect(parsed?.latitude, original.latitude);
      expect(parsed?.longitude, original.longitude);
    });

    test('returns null for empty text, map URLs, and bad ranges', () {
      expect(parseCoordinates(''), isNull);
      expect(parseCoordinates('   '), isNull);
      expect(parseCoordinates('https://maps.google.com/?q=11.5,104.9'), isNull);
      expect(parseCoordinates('abc,def'), isNull);
      expect(parseCoordinates('91,0'), isNull);
      expect(parseCoordinates('0,181'), isNull);
    });
  });

  group('applyPickedLocation', () {
    test('writes the picked coordinates into the field', () {
      final controller = TextEditingController();

      applyPickedLocation(controller, const LatLng(11.5564, 104.9282));

      expect(controller.text, '11.556400,104.928200');
      controller.dispose();
    });

    test('leaves the field unchanged when the picker is cancelled', () {
      final controller = TextEditingController(text: '11.000000,104.000000');

      applyPickedLocation(controller, null);

      expect(controller.text, '11.000000,104.000000');
      controller.dispose();
    });
  });

  group('usableMapValue', () {
    test('returns the saved map value without surrounding spaces', () {
      expect(usableMapValue(' 11.5564,104.9282 '), '11.5564,104.9282');
    });

    test('returns null when there is no map value to open', () {
      expect(usableMapValue(null), isNull);
      expect(usableMapValue(''), isNull);
      expect(usableMapValue('   '), isNull);
    });
  });
}
