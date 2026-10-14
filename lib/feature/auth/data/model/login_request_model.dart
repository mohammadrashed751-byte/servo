class LoginRequestModel {
  final String email;
  final String password;
  final bool remember;
  final String deviceToken;
  final String platform;

  LoginRequestModel({
    required this.email,
    required this.password,
    this.remember = true,
    this.deviceToken = '',
    this.platform = 'android',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'remember': remember,
    'device_token': deviceToken,
    'platform': platform,
  };
}