import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import 'trip_map_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';

class TripDetailsScreen extends ConsumerWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);
    // Watch the individual trip from provider to react to changes
    final currentTrip = ref
        .watch(tripsProvider)
        .firstWhere((t) => t.id == trip.id, orElse: () => trip);
    final isInterested = currentTrip.getIsInterested(user.id);
    final isOwner = currentTrip.driverId == user.id;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreen.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        currentTrip.mosqueName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat(
                          'EEEE, MMM d • HH:mm',
                        ).format(currentTrip.departureTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Published ${formatTimeAgo(currentTrip.createdAt)}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDriverProfile(context, isOwner),
                  const SizedBox(height: 40),
                  Text(
                    "Fluid Journey",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFluidRoute(context, currentTrip),
                  const SizedBox(height: 24),
                  _buildMosqueAddress(context, currentTrip),
                  const SizedBox(height: 40),
                  _buildStatsRow(currentTrip),
                  const SizedBox(height: 40),
                  if (!isOwner)
                    _buildActionButtons(
                      context,
                      ref,
                      currentTrip,
                      user,
                      isInterested,
                    ),
                  if (isOwner)
                    Center(
                      child: Text(
                        "You are the driver of this trip",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
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

  Widget _buildDriverProfile(BuildContext context, bool isOwner) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.secondaryBlue.withOpacity(0.1),
            child: Text(
              trip.driverName[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOwner ? "You (Driver)" : trip.driverName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Premium Driver • ⭐ 4.9",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFluidRoute(BuildContext context, Trip currentTrip) {
    final stops = [
      {
        'val': currentTrip.departurePoint,
        'icon': Icons.my_location,
        'color': AppTheme.secondaryBlue,
      },
      ...currentTrip.pickupPoints.map(
        (p) => {
          'val': p,
          'icon': Icons.push_pin_outlined,
          'color': Colors.grey,
        },
      ),
      {
        'val': currentTrip.mosqueName,
        'icon': Icons.mosque,
        'color': AppTheme.primaryGreen,
      },
    ];

    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (stop['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stop['icon'] as IconData,
                    size: 16,
                    color: stop['color'] as Color,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          stop['color'] as Color,
                          (stops[index + 1]['color'] as Color),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    stop['val'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    index == 0
                        ? "Initial Departure"
                        : (index == stops.length - 1
                              ? "Final Destination"
                              : "Pickup point"),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsRow(Trip currentTrip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.event_seat,
          "${currentTrip.seatsAvailable}",
          "left",
        ),
        _buildStatItem(Icons.timer, "25", "min"),
        _buildStatItem(Icons.security, "Verified", "trip"),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen.withOpacity(0.6)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Trip currentTrip,
    user,
    bool isInterested,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isInterested
                  ? AppTheme.secondaryBlue
                  : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            onPressed: () async {
              final canToggle = currentTrip.canToggle(user.id);
              final isFull = currentTrip.isFull;
              final isBlocked = !canToggle;

              if (isBlocked || (isFull && !isInterested)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBlocked
                        ? "You have reached the limit of interest changes for this trip."
                        : "This trip is full."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(tripsProvider.notifier)
                    .toggleInterest(currentTrip.id, user);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              !currentTrip.canToggle(user.id)
                  ? "Interaction Limited 🚫"
                  : (isInterested ? "Joined ✅" : (currentTrip.isFull ? "Trip Full 🛑" : "Join this Trip")),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(
              Icons.phone_in_talk,
              color: AppTheme.secondaryBlue,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildMosqueAddress(BuildContext context, Trip trip) {
    if (trip.mosqueAddress.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 18,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.mosqueAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripMapScreen(trip: trip),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("View on Map"),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
