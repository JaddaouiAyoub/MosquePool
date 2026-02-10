import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../../../core/theme/app_theme.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          'Trip Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDriverCard(context),
            const SizedBox(height: 28),
            _buildInfoCard(context),
            const SizedBox(height: 28),
            Text(
              "Trip Route",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildRouteTimeline(),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- DRIVER CARD ----------------

  Widget _buildDriverCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryGreen,
            child: Text(
              trip.driverName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.driverName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Driver • ⭐ 4.8",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- INFO CARD ----------------

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.mosque,
            "Destination",
            trip.mosqueName,
          ),
          const SizedBox(height: 18),
          _infoRow(
            Icons.access_time,
            "Departure",
            DateFormat('EEEE • HH:mm').format(trip.departureTime),
          ),
          const SizedBox(height: 18),
          _infoRow(
            Icons.event_seat,
            "Seats Available",
            "${trip.seatsAvailable} seats",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ],
    );
  }

  // ---------------- TIMELINE ----------------

  Widget _buildRouteTimeline() {
    final stops = [
      {
        'value': trip.departurePoint,
        'isMain': true,
      },
      ...trip.pickupPoints.map(
        (p) => {
          'value': p,
          'isMain': false,
        },
      ),
      {
        'value': trip.mosqueName,
        'isMain': true,
      },
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timelineDot(
              text: stop['value'] as String,
              isMain: stop['isMain'] as bool,
            ),
            if (!isLast) _connector(),
          ],
        );
      }),
    );
  }

  Widget _timelineDot({
    required String text,
    required bool isMain,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMain
                ? AppTheme.primaryGreen
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _connector() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 1.5,
          color: Colors.grey.shade300,
        ),
        Icon(
          Icons.arrow_forward,
          size: 14,
          color: Colors.grey.shade400,
        ),
        Container(
          width: 8,
          height: 1.5,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  // ---------------- ACTION BUTTONS ----------------

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.message),
            label: const Text("Message"),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.phone),
            label: const Text("Call"),
          ),
        ),
      ],
    );
  }
}
