import 'person_model.dart';

class ClientModel extends PersonModel {
  final String birthday;
  final String userCode;
  final double weight;

  ClientModel({
    required super.id,
    required super.name,
    required super.email,
    required this.birthday,
    required this.userCode,
    required this.weight,
  });
}
