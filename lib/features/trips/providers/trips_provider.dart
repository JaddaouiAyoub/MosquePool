import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';

final mockTripsProvider = Provider<List<Trip>>((ref) {
  return [
    Trip(
      id: '1',
      driverId: 'd1',
      driverName: 'Ahmed Malik',
      mosqueName: 'Grande Mosquée de Paris',
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      seatsAvailable: 3,
      pickupPoints: ['Porte Maillot', 'Châtelet', 'République'],
    ),
    Trip(
      id: '2',
      driverId: 'd2',
      driverName: 'Yassir Bennani',
      mosqueName: 'Mosquée de Lyon',
      departureTime: DateTime.now().add(const Duration(minutes: 45)),
      seatsAvailable: 1,
      pickupPoints: ['Place Bellecour', 'Villeurbanne'],
    ),
    Trip(
      id: '3',
      driverId: 'd1',
      driverName: 'Karim Saidi',
      mosqueName: 'Mosquée de Marseille',
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      seatsAvailable: 4,
      pickupPoints: ['Vieux Port', 'Castellane'],
    ),
  ];
});
