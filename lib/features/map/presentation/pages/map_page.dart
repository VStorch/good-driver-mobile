import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/search_results_list.dart';
import '../widgets/selected_place_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Animate map when ViewModel selects a place
  void _listenAndAnimate(MapViewModel vm) {
    if (vm.state == MapState.located) {
      _mapController.move(vm.mapCenter, vm.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        // React to place selection — animate the map
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _listenAndAnimate(vm);
        });

        return Scaffold(
          body: Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: vm.mapCenter,
                  initialZoom: vm.zoom,
                  onTap: (tapPosition, latlng) async {
                    FocusScope.of(context).unfocus();
                    await vm.reverseGeocodeAt(latlng);
                  },
                  onPositionChanged: (position, _) {
                    if (position.center != null) {
                      vm.updateCenter(position.center!);
                    }
                  },
                ),
                children: [
                  // OpenStreetMap tile layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.gooddriver.app',
                    maxZoom: 19,
                  ),

                  // Selected-place marker
                  if (vm.selectedPlace != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            vm.selectedPlace!.latitude,
                            vm.selectedPlace!.longitude,
                          ),
                          width: 48,
                          height: 56,
                          child: _DestinationMarker(),
                        ),
                      ],
                    ),
                ],
              ),

              // OSM attribution (required by tile license)
              const Positioned(
                bottom: 0,
                right: 0,
                child: _OsmAttribution(),
              ),

              // Top overlay: search bar + results
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      MapSearchBar(),
                      SearchResultsList(),
                    ],
                  ),
                ),
              ),

              // Bottom overlay: selected place info
              if (vm.selectedPlace != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  child: const SelectedPlaceCard(),
                ),

              // Zoom controls
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 96,
                child: _ZoomControls(mapController: _mapController, vm: vm),
              ),

              // My location FAB
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 180,
                child: _MyLocationButton(mapController: _mapController),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Marker pin
class _DestinationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 18),
        ),
        CustomPaint(size: const Size(12, 8), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Zoom controls
class _ZoomControls extends StatelessWidget {
  final MapController mapController;
  final MapViewModel vm;

  const _ZoomControls({required this.mapController, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapIconButton(
          icon: Icons.add,
          onTap: () => mapController.move(vm.mapCenter, mapController.camera.zoom + 1),
        ),
        const SizedBox(height: 4),
        _MapIconButton(
          icon: Icons.remove,
          onTap: () => mapController.move(vm.mapCenter, mapController.camera.zoom - 1),
        ),
      ],
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  final MapController mapController;
  const _MyLocationButton({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return _MapIconButton(
      icon: Icons.my_location_rounded,
      onTap: () {
        // TODO: integrate with geolocator when available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização GPS será integrada em breve.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
        ),
      ),
    );
  }
}

// OSM attribution
class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: Colors.white70,
      child: const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }
}