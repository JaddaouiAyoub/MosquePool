import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../../auth/models/user_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notifications_provider.dart';

// --- Profile Provider ---

class ProfileNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return UserModel(
      id: 'me',
      firstName: 'Manal',
      lastName: 'Alami',
      email: 'manal@example.com',
      phone: '+33 6 12 34 56 78',
    );
  }

  void setUser(UserModel user) {
    state = user;
  }

  void updateProfile({String? firstName, String? lastName, String? email, String? phone}) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
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
      mosqueAddress: '2 bis Place du Puits de l\'Ermite, 75005 Paris',
      mosqueLat: 48.8422,
      mosqueLng: 2.3556,
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      seatsAvailable: 3,
      pickupPoints: ['Porte Maillot', 'Châtelet', 'République'],
    ),
    Trip(
      id: '2',
      driverId: 'me',
      driverName: 'Manal Alami',
      departurePoint: 'Lyon Part-Dieu',
      mosqueName: 'Mosquée de Lyon',
      mosqueAddress: '2 Place du Pont, 69007 Lyon',
      mosqueLat: 45.7500,
      mosqueLng: 4.8400,
      departureTime: DateTime.now().add(const Duration(minutes: 45)),
      seatsAvailable: 1,
      pickupPoints: ['Place Bellecour', 'Villeurbanne'],
      interestedUsers: [
        UserModel(
          id: 'u1',
          firstName: 'Karim',
          lastName: 'Bennani',
          email: 'karim@example.com',
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
      mosqueAddress: '2 Rue de la Butte, 13001 Marseille',
      mosqueLat: 43.3000,
      mosqueLng: 5.3700,
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      seatsAvailable: 4,
      pickupPoints: ['Vieux Port', 'Castellane'],
    ),
  ];

  void toggleInterest(String tripId, UserModel currentUser) {
    final trip = state.firstWhere((t) => t.id == tripId);

    // Cannot join own trip
    if (trip.driverId == currentUser.id) return;

    final isAlreadyInterested = trip.getIsInterested(currentUser.id);

    // Emit notification to trip owner
    final notifier = ref.read(notificationsProvider.notifier);
    if (isAlreadyInterested) {
      notifier.addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tripId: tripId,
          title: '${currentUser.fullName} is no longer interested',
          body:
              '${currentUser.fullName} cancelled their seat for your trip to ${trip.mosqueName}.',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      if (trip.seatsAvailable <= 0) return;
      notifier.addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tripId: tripId,
          title: '${currentUser.fullName} is interested!',
          body:
              '${currentUser.fullName} wants to join your trip to ${trip.mosqueName}. Phone: ${currentUser.phone}',
          createdAt: DateTime.now(),
        ),
      );
    }

    state = [
      for (final t in state)
        if (t.id == tripId) _applyToggle(t, currentUser) else t,
    ];
  }

  Trip _applyToggle(Trip trip, UserModel user) {
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
