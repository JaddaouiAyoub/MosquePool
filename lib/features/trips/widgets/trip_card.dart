import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../../../core/theme/app_theme.dart';

class TripCard extends ConsumerWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);
    final isInterested = trip.getIsInterested(user.id);
    final isOwner = trip.driverId == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mosque,
                                size: 14,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trip.mosqueName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "MY TRIP",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryBlue,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm').format(trip.departureTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.secondaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 18,
                              color: AppTheme.secondaryBlue,
                            ),
                            Container(
                              width: 2,
                              height: 20,
                              color: Colors.grey.shade200,
                            ),
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppTheme.primaryGreen,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.departurePoint,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                trip.mosqueName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                trip.driverName[0],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              trip.driverName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: trip.seatsAvailable == 0
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip.seatsAvailable == 0
                                ? 'Full'
                                : '${trip.seatsAvailable} seats left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: trip.seatsAvailable == 0
                                  ? Colors.red
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isOwner)
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: isInterested
                          ? AppTheme.primaryGreen
                          : Colors.white,
                      foregroundColor: isInterested
                          ? Colors.white
                          : AppTheme.primaryGreen,
                      side: BorderSide(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                      ),
                      shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
                      elevation: 8,
                    ),
                    onPressed: () {
                      ref
                          .read(tripsProvider.notifier)
                          .toggleInterest(trip.id, user);
                    },
                    icon: Icon(
                      isInterested ? Icons.check_circle : Icons.add_task,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
