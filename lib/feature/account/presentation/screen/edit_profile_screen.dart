import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/datasources/profile_local_store.dart';
import '../../data/models/user_profile.dart';

import '../widgets/edit_profile_app_bar.dart';
import '../widgets/edit_profile_buttons.dart';
import '../widgets/edit_profile_password_field.dart';
import '../widgets/edit_profile_specialization_field.dart';
import '../widgets/edit_profile_text_field.dart';
import '../widgets/editprofilepoto.dart';
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.onChangePhoto,
    this.onChangePassword,
    this.initialProfile = UserProfile.initial,
    this.profileStore,
  });

  final VoidCallback? onChangePhoto;
  final VoidCallback? onChangePassword;
  final UserProfile initialProfile;
  final ProfileLocalStore? profileStore;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final ProfileLocalStore _profileStore;

  String? _specialization;
  bool _saving = false;

  final _specializations = ['IT', 'Design', 'Marketing', 'Engineering'];

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _specialization = profile.specialization;
    if (!_specializations.contains(profile.specialization)) {
      _specializations.add(profile.specialization);
    }
    _profileStore = widget.profileStore ?? ProfileLocalStore();
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
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
    if (!mounted || completed != true) return;
    Navigator.pop(context);
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final updated = UserProfile(
      name: _nameController.text.trim(),
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
    return PopScope<UserProfile>(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        appBar: buildEditProfileAppBar(
          context,
          onBack: () {
            if (!_saving) Navigator.pop(context);
          },
          onNotifications: () {},
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
                      EditProfilePhoto(
                        imagePath: 'assets/images/Groupp.png',
                        onTap: widget.onChangePhoto,
                      ),

                      SizedBox(height: _h(40)),

                      EditProfileTextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: AppValidators.name,
                        label: 'Full Name',
                      ),

                      SizedBox(height: _h(30)),

                      EditProfileTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
                        validator: AppValidators.email,
                        label: 'Email Address',
                      ),

                      SizedBox(height: _h(30)),

                      EditProfilePhoneField(
                        controller: _phoneController,
                        validator: AppValidators.phone,
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
