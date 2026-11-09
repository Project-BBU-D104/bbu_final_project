import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Returns the selected coordinate, or null when the picker is cancelled.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    required this.initialPosition,
    this.tileProvider,
  });
  final LatLng initialPosition;
  final TileProvider? tileProvider;
  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _selected = widget.initialPosition;
  late final _coordinates = TextEditingController(
    text: formatCoordinates(_selected),
  );
  final _map = MapController();
  String? _error;

  void _save() {
    final point = parseCoordinates(_coordinates.text);
    if (point == null) {
      setState(() => _error = 'Enter valid latitude,longitude coordinates.'.tr);
      return;
    }
    Navigator.of(context).pop(point);
  }

  @override
  void dispose() {
    _coordinates.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Pick Location',
      useTheme: true,
      onBack: () => Navigator.of(context).pop(),
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: widget.initialPosition,
                  initialZoom: 16,
                  onTap: (_, point) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _selected = point;
                      _coordinates.text = formatCoordinates(point);
                      _error = null;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        child: Icon(
                          Icons.location_pin,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                          semanticLabel: 'Selected location'.tr,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.55,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _coordinates,
                      decoration: InputDecoration(
                        labelText: 'Latitude,longitude'.tr,
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final point = parseCoordinates(value);
                        setState(() {
                          _error = null;
                          if (point != null) _selected = point;
                        });
                        if (point != null) _map.move(point, _map.camera.zoom);
                      },
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(96, 48),
                          ),
                          child: Text('Cancel'.tr),
                        ),
                        FilledButton.icon(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(96, 48),
                          ),
                          icon: const Icon(Icons.check),
                          label: Text('Save'.tr),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
