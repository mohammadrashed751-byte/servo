import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/change_password_field.dart';
import '../widgets/edit_profile_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.onSavePassword, this.onHomePage});

  final Future<void> Function(String currentPassword, String newPassword)?
  onSavePassword;
  final VoidCallback? onHomePage;
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hideCurrentPassword = false;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _hasSubmitted = false;
  bool _saving = false;

  bool get _passwordsMatch =>
      AppValidators.password(_newPassword.text) == null &&
      AppValidators.confirmPassword(_confirmPassword.text, _newPassword.text) ==
          null;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    final save = widget.onSavePassword;

    setState(() => _saving = true);
    try {
      // Until a save callback is connected, this only completes the UI flow.
      if (save != null) {
        await save(_currentPassword.text, _newPassword.text);
      }
      if (!mounted) return;
      final onHomePage = widget.onHomePage;
      if (onHomePage != null) {
        onHomePage();
      } else {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to change password. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.textTheme;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: buildEditProfileAppBar(
        context,
        title: 'Change Password',
        onBack: () => Navigator.pop(context),
        onNotifications: () {},
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(responsiveWidth(context, 32)),
                  ),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    responsiveWidth(context, 28),
                    responsiveHeight(context, 48),
                    responsiveWidth(context, 28),
                    responsiveHeight(context, 32),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _hasSubmitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Change Password',
                          style: AppTextStyles.heavyTitle,
                        ),
                        SizedBox(height: responsiveHeight(context, 8)),
                        Text(
                          'Please note changing password will required again login to the app.',
                          style: textStyles.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: responsiveHeight(context, 44)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(context, 12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ChangePasswordField(
                                controller: _currentPassword,
                                label: 'Current Password',
                                validator: AppValidators.loginPassword,
                                obscureText: _hideCurrentPassword,
                                enabled: !_saving,
                                autofillHints: const [AutofillHints.password],
                                onToggleVisibility: () => setState(() {
                                  _hideCurrentPassword = !_hideCurrentPassword;
                                }),
                              ),
                              SizedBox(height: responsiveHeight(context, 32)),
                              ChangePasswordField(
                                controller: _newPassword,
                                label: 'New Password',
                                validator: AppValidators.password,
                                obscureText: _hideNewPassword,
                                enabled: !_saving,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onChanged: (_) => setState(() {}),
                                onToggleVisibility: () => setState(() {
                                  _hideNewPassword = !_hideNewPassword;
                                }),
                              ),
                              SizedBox(height: responsiveHeight(context, 32)),
                              ChangePasswordField(
                                controller: _confirmPassword,
                                label: 'Confirm New Password',
                                obscureText: _hideConfirmPassword,
                                validator: (value) =>
                                    AppValidators.confirmPassword(
                                      value,
                                      _newPassword.text,
                                    ),
                                enabled: !_saving,
                                isValid: _passwordsMatch,
                                textInputAction: TextInputAction.done,
                                onChanged: (_) => setState(() {}),
                                onFieldSubmitted: (_) => _savePassword(),
                                onToggleVisibility: () => setState(() {
                                  _hideConfirmPassword = !_hideConfirmPassword;
                                }),
                              ),
                              SizedBox(height: responsiveHeight(context, 24)),
                              ElevatedButton(
                                onPressed: _saving ? null : _savePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  elevation: 0,
                                  minimumSize: Size(
                                    double.infinity,
                                    responsiveHeight(context, 64),
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      responsiveWidth(context, 18),
                                    ),
                                  ),
                                  textStyle: textStyles.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.surface,
                                          semanticsLabel: 'Saving password',
                                        ),
                                      )
                                    : const Text('Save Password'),
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
          ],
        ),
      ),
    );
  }
}
