import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_imp.dart';
import '../cubit/reset_password_cubit.dart';
import '../state/reset_password_state.dart';
import 'forgot_password_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../widgets/app_text_field.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, this.email, this.token});
  final String? email;
  final String? token;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cubit = ResetPasswordCubit(AuthRepositoryImpl(AuthRemoteDataSource()));

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // ---------- Getters ----------

  bool get _validLink =>
      widget.token?.trim().isNotEmpty == true &&
          AppValidators.email(widget.email) == null;

  bool get _isPasswordFormValid =>
      AppValidators.password(_passwordController.text) == null &&
          AppValidators.confirmPassword(
            _confirmPasswordController.text,
            _passwordController.text,
          ) ==
              null;

  // ---------- Actions ----------

  void _refreshPasswordState(String value) => setState(() {});

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_validLink || !(_formKey.currentState?.validate() ?? false)) return;
    _cubit.resetPassword(
      token: widget.token!,
      email: widget.email!,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _goToForgotPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  // ---------- UI helpers (بدل الـ ternary المتداخل) ----------

  String _title(ResetPasswordState state) {
    if (state is ResetPasswordSuccess) return 'Password updated successfully';
    return 'Set new password';
  }

  String _subtitle(ResetPasswordState state) {
    if (state is ResetPasswordSuccess) {
      return 'Your password has been changed. Sign in using your new password.';
    }
    if (!_validLink) {
      return 'This reset link is missing or invalid. Request a new link to continue.';
    }
    return 'Create a strong, unique new password.';
  }

  String _buttonText(ResetPasswordState state) {
    if (state is ResetPasswordSuccess) return 'Go to Login';
    if (!_validLink) return 'Request a new reset link';
    return 'Save Password';
  }

  VoidCallback? _buttonAction(ResetPasswordState state) {
    if (state is ResetPasswordLoading) return null;
    if (state is ResetPasswordSuccess) return _goToLogin;
    if (!_validLink) return _goToForgotPassword;
    return _submit;
  }

  // ---------- Lifecycle ----------

  @override
  void dispose() {
    _cubit.close();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          FocusScope.of(context).unfocus();
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(context, 30),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: responsiveHeight(context, 16)),
                    Text(_title(state), style: AppTextStyles.heavyTitle),
                    SizedBox(height: responsiveHeight(context, 16)),
                    Text(
                      _subtitle(state),
                      style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: responsiveHeight(context, 30)),

                    if (_validLink && state is! ResetPasswordSuccess) ...[
                      AppTextField(
                        labelText: 'Password',
                        controller: _passwordController,
                        validator: AppValidators.password,
                        validateMode: AutovalidateMode.onUserInteraction,
                        obscureText: _hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: _refreshPasswordState,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 30)),

                      AppTextField(
                        labelText: 'Confirm Password',
                        controller: _confirmPasswordController,
                        validator: (value) => AppValidators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        validateMode: AutovalidateMode.onUserInteraction,
                        obscureText: _hideConfirmPassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: _refreshPasswordState,
                        isValid: _isPasswordFormValid,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isPasswordFormValid)
                              const Icon(
                                Icons.check,
                                color: AppColors.success,
                                size: 20,
                              ),
                            IconButton(
                              onPressed: () => setState(
                                    () => _hideConfirmPassword =
                                !_hideConfirmPassword,
                              ),
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveHeight(context, 30)),
                    ],

                    if (state is ResetPasswordFailure) ...[
                      Text(
                        state.message,
                        style: const TextStyle(color: AppColors.failed),
                      ),
                      TextButton(
                        onPressed: _goToForgotPassword,
                        child: const Text('Request a new reset link'),
                      ),
                      SizedBox(height: responsiveHeight(context, 16)),
                    ],

                    SizedBox(
                      height: responsiveHeight(context, 66),
                      width: responsiveWidth(context, 370),
                      child: FilledButton(
                        onPressed: _buttonAction(state),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state is ResetPasswordLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          _buttonText(state),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.surface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}