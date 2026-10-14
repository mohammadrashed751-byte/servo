class CompanyProfile {
  const CompanyProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    this.avatar = '',
    this.pushEnabled = false,
  });
  static const initial = CompanyProfile(
    id: 0,
    name: '',
    email: '',
    phone: '',
    specialization: '',
  );
  final int id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String avatar;
  final bool pushEnabled;
  factory CompanyProfile.fromJson(
    Map<String, dynamic> json, {
    String specialization = '',
  }) {
    if (json['id'] is! int ||
        json['name'] is! String ||
        json['email'] is! String ||
        json['role'] != 'provider') {
      throw const FormatException('Invalid company profile');
    }
    return CompanyProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] is String ? json['phone'] as String : '',
      specialization: specialization,
      avatar: json['avatar'] is String ? json['avatar'] as String : '',
      pushEnabled: json['push_enabled'] == true,
    );
  }
  Map<String, String> toAccountUpdate() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}
