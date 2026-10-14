class UserEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String token;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.token,
  });
}