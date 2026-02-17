import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../data/trip_repository.dart';

// --- Repository Provider ---
final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(),
);

// --- Profile Provider ---

class ProfileNotifier extends Notifier<UserModel> {
  static final _emptyUser = UserModel(
    id: '',
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
  );

  @override
  UserModel build() {
    final authState = ref.watch(authStateProvider);

    authState.whenData((fbUser) {
      if (fbUser != null) {
        // Perform async fetch. Microtask ensures we don't update state during build.
        Future.microtask(() => _fetchUserData(fbUser.uid));
      } else {
        Future.microtask(() => state = _emptyUser);
      }
    });

    return _emptyUser;
  }

  Future<void> _fetchUserData(String uid) async {
    final userData = await ref.read(authRepositoryProvider).getUserData(uid);
    if (userData != null && state.id != userData.id) {
      state = userData;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    if (user != null) state = user;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );
    if (user != null) state = user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = _emptyUser;
  }

  Future<void> resendVerificationEmail() async {
    await ref.read(authRepositoryProvider).resendVerificationEmail();
  }

  Future<void> refreshAuthStatus() async {
    await ref.read(authRepositoryProvider).reloadUser();
    // Invalidate authStateProvider so that listeners like GoRouter
    // see the updated emailVerified status.
    ref.invalidate(authStateProvider);
  }

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
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
  TripRepository get _repository => ref.read(tripRepositoryProvider);
  StreamSubscription? _subscription;

  @override
  List<Trip> build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    _listenToTrips();
    return [];
  }

  void _listenToTrips() {
    _subscription?.cancel();
    _subscription = _repository.getActiveTrips().listen((trips) {
      state = trips;
    });
  }

  Future<void> toggleInterest(String tripId, UserModel currentUser) async {
    if (currentUser.id.isEmpty) return;

    final trip = state.firstWhere((t) => t.id == tripId);

    // Cannot join own trip
    if (trip.driverId == currentUser.id) return;

    final isAlreadyInterested = trip.getIsInterested(currentUser.id);

    // 1. Check Interaction Limit
    if (!trip.canToggle(currentUser.id)) {
      throw Exception(
        "Vous avez atteint la limite de modifications pour ce trajet.",
      );
    }

    // 2. Check Seat Availability if joining
    if (!isAlreadyInterested && trip.seatsAvailable <= 0) {
      throw Exception("Ce trajet est complet.");
    }

    // 3. Optimistic Update
    final originalState = state;
    final updatedTrip = trip.copyWith(
      seatsAvailable: isAlreadyInterested
          ? trip.seatsAvailable + 1
          : trip.seatsAvailable - 1,
      interestedUsers: isAlreadyInterested
          ? trip.interestedUsers.where((u) => u.id != currentUser.id).toList()
          : [...trip.interestedUsers, currentUser],
      interactionCounts: {
        ...trip.interactionCounts,
        currentUser.id: (trip.interactionCounts[currentUser.id] ?? 0) + 1,
      },
    );
    state = state.map((t) => t.id == tripId ? updatedTrip : t).toList();

    try {
      final userData = currentUser.toMap();
      if (isAlreadyInterested) {
        await _repository.leaveTrip(tripId, userData);
      } else {
        await _repository.joinTrip(tripId, userData);
      }

      // 4. Notification (Done after server success)
      final notifier = ref.read(notificationsProvider.notifier);
      notifier.addNotification(
        trip.driverId,
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tripId: tripId,
          title: isAlreadyInterested
              ? '${currentUser.fullName} n\'est plus intéressé'
              : '${currentUser.fullName} est intéressé !',
          body: isAlreadyInterested
              ? '${currentUser.fullName} a annulé sa place pour votre trajet vers ${trip.mosqueName}.'
              : '${currentUser.fullName} souhaite rejoindre votre trajet vers ${trip.mosqueName}. Tél: ${currentUser.phone}',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      // Revert on error
      state = originalState;
      rethrow;
    }
  }

  Future<void> updateTrip(Trip trip) async {
    // If ID is numeric (mock time-based), it's a new trip in our UI logic
    if (trip.id.length > 10 && int.tryParse(trip.id) != null) {
      await _repository.createTrip(trip);
    } else {
      await _repository.updateTrip(trip);
    }
  }
}

final tripsProvider = NotifierProvider<TripsNotifier, List<Trip>>(
  TripsNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  set state(String value) => super.state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final user = ref.watch(profileProvider);

  return trips.where((trip) {
    // 1. Filter out own trips
    if (trip.driverId == user.id) return false;

    // 2. Filter by search query
    if (query.isEmpty) return true;
    return trip.mosqueName.toLowerCase().contains(query) ||
        trip.departurePoint.toLowerCase().contains(query);
  }).toList();
});
