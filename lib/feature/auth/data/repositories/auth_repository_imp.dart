import '../../../../core/local_storage.dart';
import '../../../user_account/account/data/datasources/profile_local_store.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';
import '../model/reset_password_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource, {ProfileLocalStore? profileStore})
    : _profileStore = profileStore ?? ProfileLocalStore();
  final ProfileLocalStore _profileStore;

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await _dataSource.login(
      LoginRequestModel(email: email, password: password),
    );

    if (result['success'] == true) {
      final user = result['data']['user'];
      final token = result['data']['token'];

      return UserEntity(
        id: user['id'],
        name: user['name'],
        email: user['email'],
        role: user['role'],
        phone: user['phone'] ?? '',
        token: token,
      );
    }
    throw Exception(result['message']);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
  }) async {
    final result = await _dataSource.register(
      RegisterRequestModel(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        role: role,
      ),
    );
    if (result['success'] != true) {
      final errors = result['errors'];

      if (errors is Map) {
        for (final field in [
          'name',
          'email',
          'phone',
          'password',
          'password_confirmation',
          'role',
          'accept_terms',
        ]) {
          final messages = errors[field];

          if (messages is List &&
              messages.isNotEmpty &&
              messages.first is String) {
            throw Exception(messages.first);
          }
        }
      }

      throw Exception('تعذّر إنشاء الحساب. تحقّق من البيانات وحاول مجددًا.');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) => _dataSource.changePassword(
    currentPassword: currentPassword,
    password: password,
    passwordConfirmation: passwordConfirmation,
  );

  @override
  Future<void> logout() async {
    if (await LocalStorage.getToken() != null) await _dataSource.logout();
    await _profileStore.clear();
    await LocalStorage.clearAuthentication();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dataSource.resetPassword(
      ResetPasswordRequestModel(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }
}
