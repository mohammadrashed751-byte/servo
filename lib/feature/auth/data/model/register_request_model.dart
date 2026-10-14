class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;
  final String phone;
  final String locale;
  final String acceptTerms;
  final String deviceToken;
  final String platform;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    required this.phone,
    this.locale = 'ar',
    this.acceptTerms = 'yes',
    this.deviceToken = '',
    this.platform = 'android',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'role': role,
    'phone': phone,
    'locale': locale,
    'accept_terms': acceptTerms,
    'device_token': deviceToken,
    'platform': platform,
  };
}