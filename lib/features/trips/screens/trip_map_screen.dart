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

enum RouteType { planned, current }

class _TripMapScreenState extends State<TripMapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _userLocation;
  bool _isLoadingRoute = false;
  double? _distanceKm;
  double? _durationMin;
  RouteType _selectedRouteType = RouteType.planned;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _traceRouteByType(RouteType.planned);
    });
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    }
    final hours = (minutes / 60).floor();
    final remainingMins = (minutes % 60).round();
    return '${hours}h ${remainingMins}min';
  }

  Future<void> _traceRouteByType(RouteType type) async {
    setState(() => _selectedRouteType = type);

    if (type == RouteType.planned) {
      if (widget.trip.departureLat != null &&
          widget.trip.departureLng != null &&
          widget.trip.mosqueLat != null &&
          widget.trip.mosqueLng != null) {
        await _traceRoute(
          start: LatLng(widget.trip.departureLat!, widget.trip.departureLng!),
          end: LatLng(widget.trip.mosqueLat!, widget.trip.mosqueLng!),
        );
      } else {
        // Fallback or message if planned coordinates missing
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coordonnées du trajet prévu manquantes'),
            ),
          );
        }
      }
    } else {
      await _traceRouteFromUser();
    }
  }

  Future<void> _traceRouteFromUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ... same location check as before
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

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = userLocation);

    if (widget.trip.departureLat != null && widget.trip.departureLng != null) {
      await _traceRoute(
        start: userLocation,
        end: LatLng(widget.trip.departureLat!, widget.trip.departureLng!),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le point de départ du trajet n\'est pas défini.'),
          ),
        );
      }
    }
  }

  Future<void> _traceRoute({required LatLng start, required LatLng end}) async {
    setState(() {
      _isLoadingRoute = true;
      _routePoints = [];
      _distanceKm = null;
      _durationMin = null;
    });

    try {
      final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      final url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&alternatives=true&access_token=$accessToken';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List routes = data['routes'];

        if (routes.isEmpty) return;

        var shortestRoute = routes[0];
        for (var i = 1; i < routes.length; i++) {
          if (routes[i]['distance'] < shortestRoute['distance']) {
            shortestRoute = routes[i];
          }
        }

        final List coordinates = shortestRoute['geometry']['coordinates'];
        final double distance = (shortestRoute['distance'] as num).toDouble();
        final double duration = (shortestRoute['duration'] as num).toDouble();

        setState(() {
          _routePoints = coordinates
              .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
              .toList();
          _distanceKm = distance / 1000;
          _durationMin = duration / 60;
        });

        final bounds = LatLngBounds.fromPoints([start, end]);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
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
                    // Mosque Marker
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
                    // Departure Marker
                    if (widget.trip.departureLat != null &&
                        widget.trip.departureLng != null)
                      Marker(
                        point: LatLng(
                          widget.trip.departureLat!,
                          widget.trip.departureLng!,
                        ),
                        width: 100,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppTheme.secondaryBlue,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Départ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.trip_origin,
                              color: AppTheme.secondaryBlue,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    // User Location Marker (Current Position Route)
                    if (_selectedRouteType == RouteType.current &&
                        _userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 100,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Ma position',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
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
            Row(
              children: [
                Expanded(
                  child: _buildRouteTypeButton(
                    type: RouteType.planned,
                    label: 'Voir le trajet',
                    icon: Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRouteTypeButton(
                    type: RouteType.current,
                    label: 'Rejoindre le départ',
                    icon: Icons.directions_walk,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTypeButton({
    required RouteType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRouteType == type;
    return ElevatedButton.icon(
      onPressed: _isLoadingRoute ? null : () => _traceRouteByType(type),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppTheme.primaryGreen
            : Colors.grey.shade100,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 4 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
