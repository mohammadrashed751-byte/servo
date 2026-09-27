import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/contact_method_card.dart';
import '../widgets/support_page.dart';
import 'faq_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({
    super.key,
    required this.onGoHomepage,
    this.onSupportChat,
    this.onCallCenter,
    this.onEmail,
    this.supportEmail,
  });

  final VoidCallback onGoHomepage;
  final VoidCallback? onSupportChat;
  final VoidCallback? onCallCenter;
  final VoidCallback? onEmail;
  final String? supportEmail;

  @override
  Widget build(BuildContext context) {
    return SupportPage(
      appBarTitle: 'Contact Us',
      title: 'Contact Us',
      description:
          'Please choose what types of support do you need and let us know.',
      onGoHomepage: onGoHomepage,
      child: Builder(
        builder: (context) {
          final spacing = responsiveWidth(context, 16);
          final cards = [
            ContactMethodCard(
              title: 'Support Chat',
              subtitle: '24x7 Online Support',
              icon: Icons.chat_rounded,
              color: AppColors.success,
              onTap: onSupportChat,
            ),
            ContactMethodCard(
              title: 'Call Center',
              subtitle: '24x7 Customer Service',
              icon: Icons.phone_in_talk_rounded,
              color: AppColors.sunsetOrange,
              onTap: onCallCenter,
            ),
            ContactMethodCard(
              title: 'Email',
              subtitle: supportEmail ?? 'Contact our team',
              icon: Icons.email_rounded,
              color: AppColors.mediumOrchid,
              onTap: onEmail,
            ),
            ContactMethodCard(
              title: 'FAQ',
              subtitle: '+50 Answers',
              icon: Icons.help_rounded,
              color: Colors.amber,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => FaqScreen(onGoHomepage: onGoHomepage),
                ),
              ),
            ),
          ];
          return Column(
            children: [
              for (final index in [0, 2]) ...[
                if (index > 0) SizedBox(height: spacing),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[index]),
                      SizedBox(width: spacing),
                      Expanded(child: cards[index + 1]),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
