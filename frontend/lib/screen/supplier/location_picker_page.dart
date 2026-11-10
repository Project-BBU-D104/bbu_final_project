import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
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

  Widget _mapView(BuildContext context) => FlutterMap(
    mapController: _map,
    options: MapOptions(
      initialCenter: _selected,
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
              '\u00a9 OpenStreetMap contributors',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _controls(BuildContext context, {required bool wide}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: wide ? BorderRadius.circular(16) : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) ...[
              Text(
                'Location details'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the map or enter coordinates.'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _coordinates,
              decoration: InputDecoration(
                labelText: 'Latitude,longitude'.tr,
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
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
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(96, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Cancel'.tr),
                ),
                FilledButton.icon(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(96, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('Save'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = DesktopAppShell.isVisible(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: desktop
          ? null
          : CustomAppBar(
              title: 'Pick Location',
              useTheme: true,
              onBack: () => Navigator.of(context).pop(),
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Padding(
              padding: EdgeInsets.all(wide ? 32 : 0),
              child: Column(
                children: [
                  if (desktop)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back'.tr,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pick Location'.tr,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    key: const ValueKey('picker-layout'),
                    child: Flex(
                      direction: wide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(wide ? 16 : 0),
                            child: _mapView(context),
                          ),
                        ),
                        if (wide) const SizedBox(width: 24),
                        ConstrainedBox(
                          constraints: wide
                              ? const BoxConstraints(maxWidth: 320)
                              : BoxConstraints(
                                  maxHeight: constraints.maxHeight * 0.55,
                                ),
                          child: _controls(context, wide: wide),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
