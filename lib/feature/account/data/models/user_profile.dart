class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
  });

  static const initial = UserProfile(
    name: 'Mohammed',
    email: 'MOHAMMED@email.com',
    phone: '9623666131',
    specialization: 'IT',
  );

  final String name;
  final String email;
  final String phone;
  final String specialization;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    if (json['name'] is! String ||
        json['email'] is! String ||
        json['phone'] is! String ||
        json['specialization'] is! String) {
      throw const FormatException('Invalid saved profile');
    }
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialization: json['specialization'] as String,
    );
  }

  Map<String, String> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'specialization': specialization,
  };
}
