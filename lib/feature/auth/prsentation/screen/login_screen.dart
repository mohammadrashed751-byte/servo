import 'package:flutter/material.dart';
import 'package:servo/feature/auth/prsentation/screen/register_screen.dart';

import '../../../../core/shell/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_validators.dart';
import '../widgets/app_text_field.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool hidePassword = true;
  bool rememberMe = false;
  bool _hasSubmitted = false;
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
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  Text('Let’s Sign You In', style: AppTextStyles.heavyTitle),
                  SizedBox(height: responsiveHeight(context, 16)),
                  Text(
                    'Welcome back, you’ve \n been missed!',
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
                    labelText: 'Password',
                    controller: _passwordController,
                    validator: AppValidators.password,
                    validateMode: AutovalidateMode.onUserInteraction,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: AppColors.primary,
                        checkColor: AppColors.surface,
                        semanticLabel: 'Remember me',
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Remember me',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                        'Login',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.surface),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  Center(
                    child: Text(
                      'or',
                      style: AppTextStyles.textTheme.displayLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),

                  SizedBox(
                    height: responsiveHeight(context, 66),
                    width: responsiveWidth(context, 370),
                    child: FilledButton.icon(
                      onPressed: () {
                        // هون بنضيف تسجيل دخول ل جوجل بس اخلص هندلة المشروع
                      },

                      icon: Image.asset(
                        'assets/images/logo.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),

                      label: Text(
                        'Continue with Google',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.textPrimary),
                      ),

                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(context, 30)),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'don`t have an account?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sin Up',
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
