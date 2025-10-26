class UserModel {
  final String id;
  final String name;
  final String phone;

  UserModel({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
      };

  factory UserModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) throw Exception("Dados do usuário inexistentes");
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
