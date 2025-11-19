class PersonModel {
  final String id;
  final String name;
  final String email;

  PersonModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }

  static PersonModel fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  @override
  String toString() => 'PersonModel(id: $id, name: $name, email: $email)';
}
