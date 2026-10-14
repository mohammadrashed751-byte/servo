import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';

class CategoryItem extends StatelessWidget {
  static double minimumHeight(BuildContext context) {
    final label = TextPainter(
      text: TextSpan(
        text: 'Home Services\nMoving & Shifting',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    )..layout();
    final height = 68 + 8 + label.height.ceilToDouble() + 4;
    label.dispose();
    return height;
  }

  final VoidCallback? onTap;
  final String title;
  final IconData icon;

  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary,
            child: Icon(icon, color: AppColors.surface, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
