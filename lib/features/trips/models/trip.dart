enum TripStatus { active, expired, completed }

class Trip {
  final String id;
  final String driverId;
  final String driverName;
  final String departurePoint;
  final String mosqueName;
  final DateTime departureTime;
  final int seatsAvailable;
  final List<String> pickupPoints;
  final TripStatus status;

  Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.departurePoint,
    required this.mosqueName,
    required this.departureTime,
    required this.seatsAvailable,
    required this.pickupPoints,
    this.status = TripStatus.active,
  });

  bool get isFull => seatsAvailable <= 0;
}
