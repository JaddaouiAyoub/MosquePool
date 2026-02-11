import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../../auth/models/user_model.dart';

// --- Profile Provider ---

class ProfileNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return UserModel(
      id: 'me',
      fullName: 'Manal Alami',
      phone: '+33 6 12 34 56 78',
    );
  }

  void updateProfile(String name, String phone) {
    state = state.copyWith(fullName: name, phone: phone);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserModel>(
  ProfileNotifier.new,
);

// --- Trips Provider ---

class TripsNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    return _initialTrips;
  }

  static final List<Trip> _initialTrips = [
    Trip(
      id: '1',
      driverId: 'd1',
      driverName: 'Ahmed Malik',
      departurePoint: 'Nanterre Ville',
      mosqueName: 'Grande Mosquée de Paris',
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      seatsAvailable: 3,
      pickupPoints: ['Porte Maillot', 'Châtelet', 'République'],
    ),
    Trip(
      id: '2',
      driverId: 'me', // Current user's trip
      driverName: 'Manal Alami',
      departurePoint: 'Lyon Part-Dieu',
      mosqueName: 'Mosquée de Lyon',
      departureTime: DateTime.now().add(const Duration(minutes: 45)),
      seatsAvailable: 1,
      pickupPoints: ['Place Bellecour', 'Villeurbanne'],
      interestedUsers: [
        UserModel(
          id: 'u1',
          fullName: 'Karim Bennani',
          phone: '+33 7 88 99 00 11',
        ),
      ],
    ),
    Trip(
      id: '3',
      driverId: 'd3',
      driverName: 'Karim Saidi',
      departurePoint: 'Marseille Saint-Charles',
      mosqueName: 'Mosquée de Marseille',
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      seatsAvailable: 4,
      pickupPoints: ['Vieux Port', 'Castellane'],
    ),
  ];

  void toggleInterest(String tripId, UserModel currentUser) {
    state = [
      for (final trip in state)
        if (trip.id == tripId) _applyToggle(trip, currentUser) else trip,
    ];
  }

  Trip _applyToggle(Trip trip, UserModel user) {
    // Restriction: Cannot join own trip
    if (trip.driverId == user.id) return trip;

    final isAlreadyInterested = trip.getIsInterested(user.id);

    if (isAlreadyInterested) {
      return trip.copyWith(
        interestedUsers: trip.interestedUsers
            .where((u) => u.id != user.id)
            .toList(),
        seatsAvailable: trip.seatsAvailable + 1,
      );
    } else {
      // Don't join if no seats left
      if (trip.seatsAvailable <= 0) return trip;

      return trip.copyWith(
        interestedUsers: [...trip.interestedUsers, user],
        seatsAvailable: trip.seatsAvailable - 1,
      );
    }
  }

  void updateTrip(Trip updatedTrip) {
    bool exists = state.any((t) => t.id == updatedTrip.id);
    if (exists) {
      state = [
        for (final trip in state)
          if (trip.id == updatedTrip.id) updatedTrip else trip,
      ];
    } else {
      state = [updatedTrip, ...state];
    }
  }
}

final tripsProvider = NotifierProvider<TripsNotifier, List<Trip>>(
  TripsNotifier.new,
);
