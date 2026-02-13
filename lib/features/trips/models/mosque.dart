class Mosque {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'lat': latitude,
      'lng': longitude,
    };
  }

  factory Mosque.fromMap(String id, Map<String, dynamic> map) {
    return Mosque(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


// The hardcoded availableMosques list is deprecated and will be replaced by dynamic data.
