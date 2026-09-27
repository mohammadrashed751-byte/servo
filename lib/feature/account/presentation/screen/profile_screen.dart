import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shell/main_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/datasources/profile_local_store.dart';
import '../../data/models/user_profile.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import 'contact_us_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.profileStore});

  final ProfileLocalStore? profileStore;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  late final ProfileLocalStore _profileStore;
  UserProfile _profile = UserProfile.initial;
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _profileStore = widget.profileStore ?? ProfileLocalStore();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final profile = await _profileStore.load();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialProfile: _profile,
          profileStore: _profileStore,
        ),
      ),
    );
    if (!mounted || updated == null) return;
    setState(() => _profile = updated);
  }

  double _w(double value) => responsiveWidth(context, value);
  double _h(double value) => responsiveHeight(context, value);

  void _openContactUs() {
    final navigator = Navigator.of(context);
    final accountRoute = ModalRoute.of(context);
    final homeCubit = context.read<HomeCubit?>();

    void goHomepage() {
      if (!mounted) return;
      if (homeCubit != null && !homeCubit.isClosed && accountRoute != null) {
        homeCubit.selectTab(0);
        navigator.popUntil((route) => route == accountRoute);
      } else {
        navigator.pushAndRemoveUntil<void>(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    }

    navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => ContactUsScreen(onGoHomepage: goHomepage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.textTheme;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        surfaceTintColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.grid_view_rounded,
            color: AppColors.surface,
            size: _w(24),
          ),
        ),
        title: Text(
          'Profile',
          style: textStyles.headlineSmall?.copyWith(color: AppColors.surface),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: AppColors.surface,
                  size: _w(24),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: _w(5),
                    height: _w(5),
                    decoration: const BoxDecoration(
                      color: AppColors.sunsetOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load your profile.',
                    style: TextStyle(color: AppColors.surface),
                  ),
                  TextButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SafeArea(
              bottom: false,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(_w(32)),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          _w(20),
                          _h(40),
                          _w(20),
                          _h(32),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _profileDetails(),
                            SizedBox(height: _h(40)),
                            _sectionTitle('NOTIFICATIONS'),
                            SizedBox(height: _h(16)),
                            _notificationSetting(),
                            _divider(),
                            SizedBox(height: _h(28)),
                            _sectionTitle('MORE'),
                            SizedBox(height: _h(12)),
                            _menuItem(
                              icon: Icons.phone_in_talk,
                              title: 'Contact Us',
                              subtitle: 'For more information',
                              onTap: _openContactUs,
                            ),
                            _divider(),
                            _menuItem(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              onTap: () {
                                // أضف تسجيل الخروج هنا.
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _profileDetails() {
    final textStyles = AppTextStyles.textTheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_w(24)),
          child: Image.asset(
            'assets/images/Groupp.png',
            width: _w(88),
            height: _w(88),
          ),
        ),
        SizedBox(height: _h(12)),
        Text(_profile.name, style: textStyles.headlineMedium),
        SizedBox(height: _h(6)),
        Text(
          _profile.email,
          style: textStyles.bodySmall?.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: _h(14)),
        OutlinedButton(
          onPressed: _openEditProfile,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            minimumSize: Size(_w(76), _h(38)),

            textStyle: textStyles.bodyMedium,
          ),
          child: const Text('Edit'),
        ),
      ],
    );
  }

  Widget _notificationSetting() {
    final textStyles = AppTextStyles.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: _h(10)),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            size: _w(20),
            color: AppColors.textSecondary,
          ),
          SizedBox(width: _w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Push Notifications',
                  style: textStyles.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: _h(6)),
                Text(
                  'For daily update and others.',
                  style: textStyles.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: _w(8)),
          Switch(
            value: _pushNotifications,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.surface,
            inactiveTrackColor: AppColors.grey,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final textStyles = AppTextStyles.textTheme;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_w(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _h(22)),
          child: Row(
            children: [
              Icon(icon, size: _w(20), color: AppColors.textSecondary),
              SizedBox(width: _w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textStyles.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: _h(6)),
                      Text(subtitle, style: textStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              SizedBox(width: _w(8)),
              Icon(
                Icons.chevron_right_rounded,
                size: _w(24),
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
