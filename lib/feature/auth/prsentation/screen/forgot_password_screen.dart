import 'package:flutter/material.dart';
import 'package:servo/feature/auth/prsentation/screen/reset_email_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/app_text_field.dart';
import '../../../../core/utils/app_validators.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_imp.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _repository = AuthRepositoryImpl(AuthRemoteDataSource());
  bool _loading = false;
  bool _sent = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repository.forgotPassword(_email.text.trim());
      if (!mounted) return; // فكرتها انو اثناء عمل ال لودنج اذا المستخدم طلع من الصفحه  ما يصر كراش يتم استخدامها اذا استخدمت context بعدها
      _sent = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ResetEmailScreen()),
      );
    } on PasswordRecoveryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to send reset instructions. Please try again later.',
        );
      }
    } finally {
      if (mounted && !_sent) setState(() => _loading = false);
      //اذا لسا الشاشه حية والارسال فشل وقفلي ال لودنج
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveWidth(context, 30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsiveHeight(context, 16)),
                Text('Forgot Password', style: AppTextStyles.heavyTitle),
                SizedBox(height: responsiveHeight(context, 16)),
                Text(
                  'Enter your email address to receive password reset instructions.',
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: responsiveHeight(context, 30)),

                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: _email,
                    validator: AppValidators.email,
                    validateMode: AutovalidateMode.onUserInteraction,
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.failed),
                  ),
                SizedBox(height: responsiveHeight(context, 30)),

                SizedBox(
                  height: responsiveHeight(context, 66),
                  width: responsiveWidth(context, 370),
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Reset Password',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppColors.surface),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
