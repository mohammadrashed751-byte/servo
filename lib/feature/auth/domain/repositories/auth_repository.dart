import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
}
