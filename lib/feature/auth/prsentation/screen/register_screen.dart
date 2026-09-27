import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/app_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? selectedSpecialization;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool agreeToTerms = false;
  bool _hasSubmitted = false;

  bool get _confirmationIsValid {
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
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
        title: Text('Register', style: AppTextStyles.textTheme.headlineMedium),
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
                  Text('Getting Started', style: AppTextStyles.heavyTitle),
                  SizedBox(height: responsiveHeight(context, 16)),
                  Text(
                    'Seems you are new here,\nLet’s set up your profile.',
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  AppTextField(
                    labelText: 'Full Name',
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    validator: AppValidators.name,
                    validateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  AppTextField(
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: AppValidators.email,
                    validateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  AppTextField(
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    validator: AppValidators.phone,
                    validateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpecialization,
                    validator: AppValidators.specialization,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.grey,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Specialization',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsiveWidth(context, 16),
                        vertical: responsiveHeight(context, 18),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.failed),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.failed),
                      ),
                      errorStyle: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.failed),
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'plumbing',
                        child: Text('Plumbing'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'electrical',
                        child: Text('Electrical'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'carpentry',
                        child: Text('Carpentry'),
                      ),
                      DropdownMenuItem<String>(value: 'IT', child: Text('IT')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSpecialization = value;
                      });
                    },
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  AppTextField(
                    labelText: 'Password',
                    controller: _passwordController,
                    validator: AppValidators.password,
                    validateMode: AutovalidateMode.onUserInteraction,
                    onChanged: _refreshPasswordState,
                    obscureText: hidePassword,
                    autocorrect: false,
                    enableSuggestions: false,
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
                    onChanged: _refreshPasswordState,
                    isValid: _confirmationIsValid,
                    obscureText: hideConfirmPassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_confirmationIsValid)
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
                  FormField<bool>(
                    initialValue: agreeToTerms,
                    validator: AppValidators.terms,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: field.value ?? false,
                                activeColor: AppColors.primary,
                                checkColor: AppColors.surface,
                                isError: field.hasError,
                                semanticLabel: 'Agree to Terms and Conditions',
                                onChanged: (value) {
                                  final checked = value ?? false;
                                  field.didChange(checked);
                                  setState(() {
                                    agreeToTerms = checked;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        'By creating an account, you agree to our\n',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                field.errorText!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.failed),
                              ),
                            ),
                        ],
                      );
                    },
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
                        'Continue',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.surface),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 20)),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
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
