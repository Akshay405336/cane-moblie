import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  final double? lat;
  final double? lng;

  const MapPickerScreen({super.key, this.lat, this.lng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _map = MapController();

  LatLng _position = const LatLng(12.9716, 77.5946); // Bangalore fallback
  String _address = 'Detecting location...';

  bool _loading = true;

  /* ================================================= */
  /* INIT                                               */
  /* ================================================= */

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _requestPermission();

    if (widget.lat != null && widget.lng != null) {
      _position = LatLng(widget.lat!, widget.lng!);
    } else {
      await _goToCurrent();
    }

    await _updateAddress();
    _loading = false;
    setState(() {});
  }

  /* ================================================= */
  /* PERMISSION                                         */
  /* ================================================= */

  Future<void> _requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  /* ================================================= */
  /* CURRENT LOCATION                                   */
  /* ================================================= */

  Future<void> _goToCurrent() async {
    final pos = await Geolocator.getCurrentPosition();

    _position = LatLng(pos.latitude, pos.longitude);

    _map.move(_position, 16);
  }

  /* ================================================= */
  /* REVERSE GEOCODE                                    */
  /* ================================================= */

  Future<void> _updateAddress() async {
    try {
      final places = await placemarkFromCoordinates(
        _position.latitude,
        _position.longitude,
      );

      final p = places.first;

      _address =
          '${p.name}, ${p.street}, ${p.locality}, ${p.administrativeArea}';
    } catch (_) {
      _address = 'Selected location';
    }

    if (mounted) setState(() {});
  }

  /* ================================================= */
  /* UI                                                 */
  /* ================================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ================= MAP =================
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _position,
              initialZoom: 16,

              onPositionChanged: (pos, _) {
                _position = pos.center!;
              },

              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateAddress();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.caneandtender',
              ),
            ],
          ),

          /// center pin
          const Center(
            child: Icon(Icons.location_pin,
                size: 42, color: Colors.red),
          ),

          /// ================= TOP BAR =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ================= BOTTOM CARD =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// address text
                  Text(
                    _loading ? 'Detecting location...' : _address,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  /// confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.pop(context, {
                                "address": _address,
                                "lat": _position.latitude,
                                "lng": _position.longitude,
                              });
                            },
                      child: const Text('Confirm location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
