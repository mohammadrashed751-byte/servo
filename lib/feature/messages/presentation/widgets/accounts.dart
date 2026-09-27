import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/chat_screen.dart';

class Accounts extends StatelessWidget {
  const Accounts({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: responsiveWidth(context, 76),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: responsiveWidth(context, 56),
                height: responsiveWidth(context, 56),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/images/Rectangle1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: responsiveWidth(context, 14),
                  height: responsiveHeight(context, 14),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.dark, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: responsiveWidth(context, 10)),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CODERZ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Online',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),

          IconButton(
            tooltip: 'Message provider',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withAlpha(20),
              foregroundColor: AppColors.primary,
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 26),
          ),
        ],
      ),
    );
  }
}
