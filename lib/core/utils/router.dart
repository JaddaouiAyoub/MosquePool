import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/trips/models/trip.dart';
import '../../features/trips/screens/home_screen.dart';
import '../../features/trips/screens/my_trips_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/trips/screens/add_trip_screen.dart';
import '../../features/trips/screens/trip_details_screen.dart';
import '../../features/auth/screens/messages_screen.dart';
import '../../shared/widgets/main_navigation_wrapper.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorMessagesKey = GlobalKey<NavigatorState>(
  debugLabel: 'messages',
);
final _shellNavigatorMyTripsKey = GlobalKey<NavigatorState>(
  debugLabel: 'myTrips',
);
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'profile',
);

final routerConfig = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationWrapper(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMessagesKey,
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMyTripsKey,
          routes: [
            GoRoute(
              path: '/my-trips',
              builder: (context, state) => const MyTripsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-trip',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTripScreen(),
    ),
    GoRoute(
      path: '/trip-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final trip = state.extra as Trip;
        return TripDetailsScreen(trip: trip);
      },
    ),
  ],
);
