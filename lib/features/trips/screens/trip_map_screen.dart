import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/trip.dart';
import '../../../core/theme/app_theme.dart';

class TripMapScreen extends StatefulWidget {
  final Trip trip;

  const TripMapScreen({super.key, required this.trip});

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _userLocation;
  bool _isLoadingRoute = false;
  double? _distanceKm;
  double? _durationMin;

  @override
  void initState() {
    super.initState();
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    }
    final hours = (minutes / 60).floor();
    final remainingMins = (minutes % 60).round();
    return '${hours}h ${remainingMins}min';
  }

  Future<void> _traceRoute() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Services de localisation désactivés'),
            content: const Text(
              'Veuillez activer les services de localisation pour tracer l\'itinéraire.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.pop(context);
                },
                child: const Text('Paramètres'),
              ),
            ],
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission désactivée'),
            content: const Text(
              'La permission de localisation est désactivée de façon permanente. Veuillez l\'activer dans les paramètres de l\'application.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Ouvrir les paramètres'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _routePoints = [];
      _distanceKm = null;
      _durationMin = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      setState(() => _userLocation = userLocation);

      final mosqueLat = widget.trip.mosqueLat;
      final mosqueLng = widget.trip.mosqueLng;

      if (mosqueLat == null || mosqueLng == null) return;

      final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      // Use alternatives=true to find multiple routes, then we'll pick the shortest
      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation.longitude},${userLocation.latitude};$mosqueLng,$mosqueLat?geometries=geojson&alternatives=true&access_token=$accessToken';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List routes = data['routes'];

        if (routes.isEmpty) return;

        // Find the route with the minimum distance
        var shortestRoute = routes[0];
        for (var i = 1; i < routes.length; i++) {
          if (routes[i]['distance'] < shortestRoute['distance']) {
            shortestRoute = routes[i];
          }
        }

        final List coordinates = shortestRoute['geometry']['coordinates'];
        final double distance = (shortestRoute['distance'] as num)
            .toDouble(); // meters
        final double duration = (shortestRoute['duration'] as num)
            .toDouble(); // seconds

        setState(() {
          _routePoints = coordinates
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          _distanceKm = distance / 1000;
          _durationMin = duration / 60;
        });

        // Zoom to show both points
        final bounds = LatLngBounds.fromPoints([
          userLocation,
          LatLng(mosqueLat, mosqueLng),
        ]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du calcul de l\'itinéraire: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosqueLat = widget.trip.mosqueLat;
    final mosqueLng = widget.trip.mosqueLng;
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: mosqueLat != null && mosqueLng != null
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(mosqueLat, mosqueLng),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$accessToken',
                  additionalOptions: {'access_token': accessToken ?? ''},
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: AppTheme.primaryGreen,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(mosqueLat, mosqueLng),
                      width: 150,
                      height: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.trip.mosqueName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            )
          : const Center(
              child: Text("Coordonnées de la mosquée non disponibles"),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.trip.mosqueName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.trip.mosqueAddress,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
            if (_distanceKm != null && _durationMin != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRouteInfoItem(
                      Icons.directions_car,
                      'Distance',
                      '${_distanceKm!.toStringAsFixed(1)} km',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                    _buildRouteInfoItem(
                      Icons.timer,
                      'Durée',
                      _formatDuration(_durationMin!),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingRoute ? null : _traceRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoadingRoute
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Tracer l'itinéraire"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryGreen),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}
