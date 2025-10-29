class UserModel {
  final String id;
  final String name;
  final String email;
  final String code;
  final int level;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.code,
    required this.level,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'code': code,
        'level': level,
      };

  factory UserModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) throw Exception("Dados do usuário inexistentes");
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      code: map['code'] ?? '',
      level: map['level'] is int
          ? map['level']
          : int.tryParse(map['level'].toString()) ?? 1,
    );
  }

  // 🔹 Nome do cargo
  String get role => level == 2 ? 'Admin' : 'Usuário';

  // 🔹 Verificação rápida
  bool get isAdmin => level == 2;
}
