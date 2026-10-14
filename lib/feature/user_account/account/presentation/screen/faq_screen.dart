import 'package:servo/core/network/marketplace_api.dart';
import 'package:servo/core/widgets/api_content.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/responsive.dart';
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
      child: ApiContent<List<JsonMap>>(
        load: () => MarketplaceApi().list('faqs'),
        builder: (context, groups) => Column(
          children: [
            for (final group in groups) ...[
              FaqSection(
                title: apiText(group['name']),
                entries: [
                  for (final item in (group['faqs'] as List? ?? []))
                    FaqEntry(
                      question: apiText(item['question']),
                      answer: apiText(item['answer']),
                    ),
                ],
              ),
              SizedBox(height: responsiveHeight(context, 40)),
            ],
          ],
        ),
      ),
    );
  }
}
