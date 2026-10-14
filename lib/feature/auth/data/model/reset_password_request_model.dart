class ResetPasswordRequestModel {
  final String token;
  final String email;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestModel({
    required this.token,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}