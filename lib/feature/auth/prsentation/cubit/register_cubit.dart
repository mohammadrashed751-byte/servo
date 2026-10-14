import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository_imp.dart';
import '../state/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepositoryImpl _repository;

  RegisterCubit(this._repository) : super(RegisterInitial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
  }) async {
    emit(RegisterLoading());

    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        role: role,
      );

      emit(RegisterSuccess());

    } catch (e) {
      emit(RegisterFailure(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}