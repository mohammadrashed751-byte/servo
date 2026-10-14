import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local_storage.dart';
import '../../data/repositories/auth_repository_imp.dart';
import '../state/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepositoryImpl _repository;
  LoginCubit(this._repository) : super(LoginInitial());
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      final user = await _repository.login(email, password);
      await LocalStorage.saveToken(user.token);
      await LocalStorage.saveRole(user.role);
      emit(LoginSuccess(role: user.role));
    } catch (e) {
      emit(LoginFailure(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}