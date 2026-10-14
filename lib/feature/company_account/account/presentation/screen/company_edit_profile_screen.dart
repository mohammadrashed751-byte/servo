import 'package:servo/core/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_validators.dart';
import '../../../../../core/utils/responsive.dart';
import '../../data/datasources/company_profile_store.dart';
import '../../data/models/company_profile.dart';

import '../widgets/edit_profile_app_bar.dart';
import '../widgets/change_password_button.dart';
import '../widgets/edit_profile_password_field.dart';
import '../widgets/edit_profile_specialization_field.dart';
import '../widgets/edit_profile_text_field.dart';
import 'package:servo/core/widgets/image_upload.dart';
import 'company_change_password_screen.dart';

class CompanyEditProfileScreen extends StatefulWidget {
  const CompanyEditProfileScreen({
    super.key,
    this.onChangePhoto,
    this.onChangePassword,
    this.initialProfile = CompanyProfile.initial,
    this.profileStore,
  });

  final VoidCallback? onChangePhoto;
  final VoidCallback? onChangePassword;
  final CompanyProfile initialProfile;
  final CompanyProfileStore? profileStore;

  @override
  State<CompanyEditProfileScreen> createState() =>
      _CompanyEditProfileScreenState();
}

class _CompanyEditProfileScreenState extends State<CompanyEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final CompanyProfileStore _profileStore;

  String? _specialization;
  bool _saving = false;
  late String _avatar = widget.initialProfile.avatar;

  final _specializations = ['IT', 'Design', 'Marketing', 'Engineering'];

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _specialization = profile.specialization.isEmpty
        ? null
        : profile.specialization;
    if (profile.specialization.isNotEmpty &&
        !_specializations.contains(profile.specialization)) {
      _specializations.add(profile.specialization);
    }
    _profileStore = widget.profileStore ?? CompanyProfileStore();
  }

  double _w(double value) => responsiveWidth(context, value);

  double _h(double value) => responsiveHeight(context, value);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openChangePassword() async {
    final onChangePassword = widget.onChangePassword;
    if (onChangePassword != null) {
      onChangePassword();
      return;
    }
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CompanyChangePasswordScreen()),
    );
    if (!mounted || completed != true) return;
    Navigator.pop(context);
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Enter a phone number';
    if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(phone) || phone.length > 20) {
      return 'Enter a valid phone number';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15
        ? null
        : 'Enter a valid phone number';
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final updated = CompanyProfile(
      id: widget.initialProfile.id,
      pushEnabled: widget.initialProfile.pushEnabled,
      name: _nameController.text.trim(),
      avatar: _avatar,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      specialization: _specialization!,
    );
    setState(() => _saving = true);
    try {
      await _profileStore.save(updated);
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save changes. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<CompanyProfile>(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        appBar: buildEditProfileAppBar(
          context,
          onBack: () {
            if (!_saving) Navigator.pop(context);
          },
          onNotifications: () => Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_w(32)),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(_w(30), _h(44), _w(30), _h(32)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AvatarEditor(
                        path: _avatar,
                        onChanged: (value) => setState(() => _avatar = value),
                        onTap: widget.onChangePhoto,
                      ),

                      SizedBox(height: _h(40)),

                      EditProfileTextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: AppValidators.name,
                        label: 'Company Name',
                      ),

                      SizedBox(height: _h(30)),

                      EditProfileTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        validator: AppValidators.email,
                        label: 'Company Email',
                      ),

                      SizedBox(height: _h(30)),

                      EditProfilePhoneField(
                        controller: _phoneController,
                        validator: _validatePhone,
                        onChanged: (_) => setState(() {}),
                      ),

                      SizedBox(height: _h(30)),

                      EditProfileSpecializationField(
                        value: _specialization,
                        specializations: _specializations,
                        validator: AppValidators.specialization,
                        onChanged: (value) {
                          setState(() {
                            _specialization = value;
                          });
                        },
                      ),

                      SizedBox(height: _h(30)),
                      const EditProfilePasswordField(),

                      SizedBox(height: _h(22)),

                      ChangePasswordButton(onPressed: _openChangePassword),

                      SizedBox(height: _h(14)),

                      SaveProfileButton(
                        onPressed: _saveChanges,
                        isSaving: _saving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
