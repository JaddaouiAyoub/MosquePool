class UserModel {
  final String id;
  final String fullName;
  final String phone;

  UserModel({required this.id, required this.fullName, required this.phone});

  UserModel copyWith({String? fullName, String? phone}) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
    );
  }
}
