import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trips_provider.dart';
import '../widgets/trip_card.dart';
import '../models/trip.dart';
import 'trip_details_screen.dart';
import 'edit_trip_screen.dart';
import '../../../core/theme/app_theme.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final user = ref.watch(profileProvider);

    final myPublishedTrips = trips.where((t) => t.driverId == user.id).toList();
    final myJoinedTrips = trips
        .where((t) => t.getIsInterested(user.id))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'My Journeys',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Published"),
              Tab(text: "Joined"),
            ],
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTripsList(context, ref, myPublishedTrips, isPublished: true),
            _buildTripsList(context, ref, myJoinedTrips, isPublished: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(
    BuildContext context,
    WidgetRef ref,
    List<Trip> trips, {
    required bool isPublished,
  }) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPublished ? Icons.drive_eta : Icons.event_available,
              size: 80,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              isPublished
                  ? "You haven't published any trips yet."
                  : "You haven't joined any trips yet.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Column(
          children: [
            TripCard(
              trip: trip,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsScreen(trip: trip),
                ),
              ),
            ),
            if (isPublished) ...[
              _buildParticipantSection(context, trip),
              const SizedBox(height: 12),
              _buildTripActions(context, trip),
              const SizedBox(height: 32),
            ],
          ],
        );
      },
    );
  }

  Widget _buildParticipantSection(BuildContext context, Trip trip) {
    if (trip.interestedUsers.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 18,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                "Interested Participants (${trip.interestedUsers.length})",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...trip.interestedUsers.map(
            (participant) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        participant.phone,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: AppTheme.secondaryBlue,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripActions(BuildContext context, Trip trip) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTripScreen(trip: trip),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Modify"),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.all(12),
          ),
          onPressed: () {},
          icon: const Icon(Icons.delete_outline, size: 18),
        ),
      ],
    );
  }
}
