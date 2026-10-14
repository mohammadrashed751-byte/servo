import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_validators.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_imp.dart';
import '../state/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepositoryImpl _repository;
  ResetPasswordCubit(this._repository) : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (isClosed ||
        state is ResetPasswordLoading ||
        state is ResetPasswordSuccess) {
      return;
    }
    final validation =
        token.trim().isEmpty || AppValidators.email(email) != null
        ? 'This reset link is invalid. Request a new link.'
        : AppValidators.password(password) ??
              AppValidators.confirmPassword(passwordConfirmation, password);
    if (validation != null) {
      emit(ResetPasswordFailure(message: validation));
      return;
    }
    emit(ResetPasswordLoading());
    try {
      await _repository.resetPassword(
        token: token,
        email: email.trim(),
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (!isClosed) emit(ResetPasswordSuccess());
    } on PasswordRecoveryException catch (error) {
      if (!isClosed) emit(ResetPasswordFailure(message: error.message));
    } catch (_) {
      if (!isClosed) {
        emit(
          ResetPasswordFailure(
            message: 'Unable to reset your password. Please try again later.',
          ),
        );
      }
    }
  }
}
