import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../widgets/app_text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool _hasSubmitted = false;

  bool get passwordsMatch {
    return AppValidators.password(_passwordController.text) == null &&
        AppValidators.confirmPassword(
              _confirmPasswordController.text,
              _passwordController.text,
            ) ==
            null;
  }

  void _refreshPasswordState(String value) {
    setState(() {});
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      _hasSubmitted = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return; //هون في المسقبل مكان ربط الخدمه الفعليه
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            child: Form(
              key: _formKey,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsiveHeight(context, 16)),
                  Text('Set new password', style: AppTextStyles.heavyTitle),
                  SizedBox(height: responsiveHeight(context, 16)),
                  Text(
                    'Create strong and secured \n new password.',
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  AppTextField(
                    labelText: 'Password',
                    controller: _passwordController,
                    validator: AppValidators.password,
                    validateMode: AutovalidateMode.onUserInteraction,
                    obscureText: hidePassword,
                    autocorrect: false,
                    enableSuggestions: false,

                    onChanged: _refreshPasswordState,

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
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
                    obscureText: hideConfirmPassword,
                    autocorrect: false,
                    enableSuggestions: false,

                    onChanged: _refreshPasswordState,

                    isValid: passwordsMatch,

                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (passwordsMatch)
                          const Icon(
                            Icons.check,
                            color: AppColors.success,
                            size: 20,
                          ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            hideConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  SizedBox(
                    height: responsiveHeight(context, 66),
                    width: responsiveWidth(context, 370),
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Save Password',
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
      ),
    );
  }
}
