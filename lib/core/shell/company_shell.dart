import 'package:flutter/material.dart';
import 'package:servo/feature/company_account/account/presentation/screen/company_profile_screen.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/widgets/app_bottom_navigation_bar.dart';
import 'package:servo/feature/company_account/home/presentation/screen/company_dashboard_screen.dart';

import '../../feature/company_account/message/presentation/company_message_screen.dart';

class CompanyShell extends StatefulWidget {
  const CompanyShell({super.key});

  @override
  State<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends State<CompanyShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const CompanyDashboardScreen(),
          const CompanyMessageScreen(),
          CompanyProfileScreen(
            onGoHomepage: () => setState(() => _currentIndex = 0),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          AppNavigationItem(icon: Icons.home_rounded, label: 'Home'),
          AppNavigationItem(icon: Icons.chat_rounded, label: 'Messages'),
          AppNavigationItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
