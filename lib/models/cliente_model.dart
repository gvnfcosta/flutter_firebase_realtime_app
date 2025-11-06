import 'package:flutter_firebase_realtime_app/models/person_model.dart';

class ClientModel extends PersonModel {
  final String birthday;
  final String phone;
  final String userCode;
  final double weight;

  ClientModel({
    required super.id,
    required super.name,
    required super.email,
    required this.phone,
    required this.birthday,
    required this.userCode,
    required this.weight,
  });

  /// Converte o objeto em um mapa para salvar no Firebase
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'userCode': userCode,
      'weight': weight,
    };
  }

  /// Cria uma instância de ClientModel a partir de um mapa
  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      birthday: map['birthday'] ?? '',
      userCode: map['userCode'] ?? '',
      weight: (map['weight'] is num) ? (map['weight'] as num).toDouble() : 0.0,
    );
  }

  /// Retorna uma cópia modificada do modelo
  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthday,
    String? userCode,
    double? weight,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      userCode: userCode ?? this.userCode,
      weight: weight ?? this.weight,
    );
  }
}
