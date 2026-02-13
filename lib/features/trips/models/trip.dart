import '../../auth/models/user_model.dart';

enum TripStatus { active, expired, completed }

class Trip {
  final String id;
  final String driverId;
  final String driverName;
  final String departurePoint;
  final String mosqueName;
  final String mosqueAddress;
  final double? mosqueLat;
  final double? mosqueLng;
  final DateTime departureTime;
  final int seatsAvailable;
  final List<String> pickupPoints;
  final TripStatus status;
  final List<UserModel> interestedUsers;

  Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.departurePoint,
    required this.mosqueName,
    this.mosqueAddress = '',
    this.mosqueLat,
    this.mosqueLng,
    required this.departureTime,
    required this.seatsAvailable,
    required this.pickupPoints,
    this.status = TripStatus.active,
    this.interestedUsers = const [],
  });

  bool get isFull => seatsAvailable <= 0;

  bool getIsInterested(String userId) =>
      interestedUsers.any((u) => u.id == userId);

  Trip copyWith({
    int? seatsAvailable,
    List<UserModel>? interestedUsers,
    String? departurePoint,
    String? mosqueName,
    String? mosqueAddress,
    double? mosqueLat,
    double? mosqueLng,
    DateTime? departureTime,
    List<String>? pickupPoints,
  }) {
    return Trip(
      id: id,
      driverId: driverId,
      driverName: driverName,
      departurePoint: departurePoint ?? this.departurePoint,
      mosqueName: mosqueName ?? this.mosqueName,
      mosqueAddress: mosqueAddress ?? this.mosqueAddress,
      mosqueLat: mosqueLat ?? this.mosqueLat,
      mosqueLng: mosqueLng ?? this.mosqueLng,
      departureTime: departureTime ?? this.departureTime,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      status: status,
      interestedUsers: interestedUsers ?? this.interestedUsers,
    );
  }
}
