class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'member',
      gender: json['gender'] ?? 'male',
    );
  }

  bool get isPresident => role == 'president';
  bool get isCashier => role == 'cashier';
  bool get isRegistrar => role == 'registrar';
  bool get isMember => role == 'member';
}
