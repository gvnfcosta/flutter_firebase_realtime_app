import 'person_model.dart';

class UserModel extends PersonModel {
  final String code;
  final String logoUrl;
  final int level;

  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required this.code,
    required this.logoUrl,
    required this.level,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'code': code,
      'logoUrl': logoUrl,
      'level': level,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      code: map['code'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      level: map['level'] ?? '',
    );
  }

  // 🔹 Nome do cargo
  String get role => level == 2 ? 'Admin' : 'Usuário';

  // 🔹 Verificação rápida
  bool get isAdmin => level == 2;
}
