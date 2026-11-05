import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen map used to pick a location for a supplier.
///
/// Pops with the selected [LatLng] when the user taps Save.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    required this.initialPosition,
    this.tileProvider,
  });

  final LatLng initialPosition;

  /// Optional tile provider, mainly useful for tests or custom tile sources.
  final TileProvider? tileProvider;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _selected = widget.initialPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pick Location'.tr,
        onBack: () => Navigator.of(context).pop(),
        showBack: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.initialPosition,
          initialZoom: 16,
          onTap: (_, point) {
            setState(() => _selected = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.frontend',
            tileProvider: widget.tileProvider,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selected,
                width: 48,
                height: 48,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_pin,
                  size: 48,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_selected),
          icon: const Icon(Icons.check),
          label: const Text('Save'),
        ),
      ),
    );
  }
}
