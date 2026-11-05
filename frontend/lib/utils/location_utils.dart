import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

/// Default center used when the user has no saved or current location.
const LatLng defaultMapLocation = LatLng(11.5564, 104.9282);

final RegExp _coordinatePattern = RegExp(
  r'^-?\d+(?:\.\d+)?\s*,\s*-?\d+(?:\.\d+)?$',
);

/// Formats a location the way the supplier Map field stores it.
String formatCoordinates(LatLng location) {
  return '${location.latitude.toStringAsFixed(6)},'
      '${location.longitude.toStringAsFixed(6)}';
}

/// Parses a `latitude,longitude` value, returning null for anything else.
LatLng? parseCoordinates(String value) {
  final text = value.trim();
  if (!_coordinatePattern.hasMatch(text)) {
    return null;
  }

  final parts = text.split(',');
  final latitude = double.parse(parts[0].trim());
  final longitude = double.parse(parts[1].trim());

  if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
    return null;
  }

  return LatLng(latitude, longitude);
}

/// Writes a picked location into the supplier Map field.
///
/// Does nothing when the user closed the picker without saving.
void applyPickedLocation(TextEditingController controller, LatLng? location) {
  if (location == null) {
    return;
  }

  controller.text = formatCoordinates(location);
}

/// Returns the saved map value ready to open, or null when it is empty.
String? usableMapValue(String? value) {
  final map = value?.trim() ?? '';
  return map.isEmpty ? null : map;
}
