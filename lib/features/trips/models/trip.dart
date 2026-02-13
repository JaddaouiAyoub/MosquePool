import '../../auth/models/user_model.dart';

enum TripStatus { active, expired, completed }

class Trip {
  final String id;
  final String? mosqueId;
  final String driverId;
  final String driverName;
  final String departurePoint;
  final String mosqueName;
  final String mosqueAddress;
  final double? mosqueLat;
  final double? mosqueLng;
  final DateTime departureTime;
  final DateTime createdAt;
  final int seatsAvailable;
  final List<String> pickupPoints;
  final TripStatus status;
  final List<UserModel> interestedUsers;
  final Map<String, int> interactionCounts;

  Trip({
    required this.id,
    this.mosqueId,
    required this.driverId,
    required this.driverName,
    required this.departurePoint,
    required this.mosqueName,
    this.mosqueAddress = '',
    this.mosqueLat,
    this.mosqueLng,
    required this.departureTime,
    required this.createdAt,
    required this.seatsAvailable,
    required this.pickupPoints,
    this.status = TripStatus.active,
    this.interestedUsers = const [],
    this.interactionCounts = const {},
  });

  bool get isFull => seatsAvailable <= 0;

  bool getIsInterested(String userId) =>
      interestedUsers.any((u) => u.id == userId);

  bool canToggle(String userId) => (interactionCounts[userId] ?? 0) < 4;

  Trip copyWith({
    int? seatsAvailable,
    List<UserModel>? interestedUsers,
    String? mosqueId,
    String? departurePoint,
    String? mosqueName,
    String? mosqueAddress,
    double? mosqueLat,
    double? mosqueLng,
    DateTime? departureTime,
    DateTime? createdAt,
    List<String>? pickupPoints,
    Map<String, int>? interactionCounts,
  }) {
    return Trip(
      id: id,
      mosqueId: mosqueId ?? this.mosqueId,
      driverId: driverId,
      driverName: driverName,
      departurePoint: departurePoint ?? this.departurePoint,
      mosqueName: mosqueName ?? this.mosqueName,
      mosqueAddress: mosqueAddress ?? this.mosqueAddress,
      mosqueLat: mosqueLat ?? this.mosqueLat,
      mosqueLng: mosqueLng ?? this.mosqueLng,
      departureTime: departureTime ?? this.departureTime,
      createdAt: createdAt ?? this.createdAt,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      status: status,
      interestedUsers: interestedUsers ?? this.interestedUsers,
      interactionCounts: interactionCounts ?? this.interactionCounts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mosqueId': mosqueId,
      'driverId': driverId,
      'driverName': driverName,
      'departurePoint': departurePoint,
      'mosqueName': mosqueName,
      'mosqueAddress': mosqueAddress,
      'mosqueLat': mosqueLat,
      'mosqueLng': mosqueLng,
      'departureTime': departureTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'seatsAvailable': seatsAvailable,
      'pickupPoints': pickupPoints,
      'status': status.name,
      'interactionCounts': interactionCounts,
      'interestedUsers': interestedUsers.map((u) => {
        'id': u.id,
        'firstName': u.firstName,
        'lastName': u.lastName,
        'email': u.email,
        'phone': u.phone,
      }).toList(),
    };
  }

  factory Trip.fromMap(String id, Map<String, dynamic> map) {
    return Trip(
      id: id,
      mosqueId: map['mosqueId'],
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      departurePoint: map['departurePoint'] ?? '',
      mosqueName: map['mosqueName'] ?? '',
      mosqueAddress: map['mosqueAddress'] ?? '',
      mosqueLat: (map['mosqueLat'] as num?)?.toDouble(),
      mosqueLng: (map['mosqueLng'] as num?)?.toDouble(),
      departureTime: DateTime.parse(map['departureTime']),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      seatsAvailable: map['seatsAvailable'] ?? 0,
      pickupPoints: List<String>.from(map['pickupPoints'] ?? []),
      status: TripStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TripStatus.active,
      ),
      interactionCounts: Map<String, int>.from(map['interactionCounts'] ?? {}),
      interestedUsers: (map['interestedUsers'] as List? ?? [])
          .map((u) => UserModel(
                id: u['id'],
                firstName: u['firstName'] ?? '',
                lastName: u['lastName'] ?? '',
                email: u['email'] ?? '',
                phone: u['phone'] ?? '',
              ))
          .toList(),
    );
  }
}
