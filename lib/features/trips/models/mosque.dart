class Mosque {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'lat': latitude,
      'lng': longitude,
    };
  }

  factory Mosque.fromMap(String id, Map<String, dynamic> map) {
    return Mosque(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// The hardcoded availableMosques list is deprecated and will be replaced by dynamic data.
