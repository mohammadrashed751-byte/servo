import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../widgets/faq_section.dart';
import '../widgets/support_page.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key, required this.onGoHomepage});

  final VoidCallback onGoHomepage;

  @override
  Widget build(BuildContext context) {
    return SupportPage(
      appBarTitle: 'FAQs',
      title: 'FAQ',
      description:
          'Find important information and updates about\nany recent changes and fees here.',
      onGoHomepage: onGoHomepage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FaqSection(
            title: 'General',
            entries: [
              FaqEntry(
                question: 'How do I create an account?',
                answer:
                    'Open the registration page, enter your details and complete the required fields to create your account.',
              ),
              FaqEntry(
                question: 'Can I change my email later?',
                answer:
                    'Open Profile, tap Edit, update your email address and select Save Changes.',
              ),
              FaqEntry(
                question: 'I forgot my password. What should I do?',
                answer:
                    'Select Forgot Password on the login page and follow the password reset steps.',
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 40)),
          const FaqSection(
            title: 'Contact',
            entries: [
              FaqEntry(
                question: 'How do I post a service?',
                answer:
                    'Contact the support team for help with listing a service.',
              ),
              FaqEntry(
                question: 'How can I book a service?',
                answer:
                    'Browse available services, select the one you want, choose a time slot, and confirm your booking.',
                initiallyExpanded: true,
              ),
              FaqEntry(
                question: 'Can I cancel an order?',
                answer:
                    'Contact support with your booking details to ask about the cancellation options for your order.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
