import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.description_rounded,
    Icons.chat_rounded,
    Icons.person_rounded,
  ];

  static const List<String> _labels = [
    'Home',
    'Bookings',
    'Messages',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = (constraints.maxWidth / 430)
                  .clamp(0.75, 1.2)
                  .toDouble();

              final itemWidth = constraints.maxWidth / _icons.length;
              final circleSize = 68 * scale;

              final labelHeight =
                  MediaQuery.textScalerOf(context).scale(14) * 1.4;

              final barHeight = 86 * scale + labelHeight + 12;

              final isRtl = Directionality.of(context) == TextDirection.rtl;

              final visualIndex = isRtl
                  ? _icons.length - 1 - currentIndex
                  : currentIndex;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: visualIndex.toDouble(),
                  end: visualIndex.toDouble(),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                builder: (context, animatedIndex, child) {
                  final centerX = itemWidth * (animatedIndex + 0.5);

                  return SizedBox(
                    height: barHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _NavigationBackgroundPainter(
                              centerX: centerX,
                              scale: scale,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 8 * scale,
                          left: centerX - circleSize / 2,
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: Container(
                                width: circleSize,
                                height: circleSize,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _icons[currentIndex],
                                  color: AppColors.primary,
                                  size: 32 * scale,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: Row(
                            children: List.generate(_icons.length, (index) {
                              final isSelected = currentIndex == index;

                              return Expanded(
                                child: Semantics(
                                  button: true,
                                  selected: isSelected,
                                  label: _labels[index],
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => onTap(index),
                                    child: ExcludeSemantics(
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          if (!isSelected)
                                            Positioned(
                                              top: 53 * scale,
                                              child: Icon(
                                                _icons[index],
                                                color: AppColors.surface,
                                                size: 26 * scale,
                                              ),
                                            ),
                                          if (isSelected)
                                            Positioned(
                                              top: 86 * scale,
                                              left: 2,
                                              right: 2,
                                              child: Text(
                                                _labels[index],
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: AppColors.surface,
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          ColoredBox(
            color: AppColors.dark,
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationBackgroundPainter extends CustomPainter {
  final double centerX;
  final double scale;

  const _NavigationBackgroundPainter({
    required this.centerX,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = 38 * scale;

    final path = Path()
      ..moveTo(0, baseline)
      ..lineTo(centerX - 70 * scale, baseline)
      ..cubicTo(
        centerX - 46 * scale,
        baseline,
        centerX - 46 * scale,
        0,
        centerX,
        0,
      )
      ..cubicTo(
        centerX + 46 * scale,
        0,
        centerX + 46 * scale,
        baseline,
        centerX + 70 * scale,
        baseline,
      )
      ..lineTo(size.width, baseline)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.dark
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _NavigationBackgroundPainter oldDelegate) {
    return oldDelegate.centerX != centerX || oldDelegate.scale != scale;
  }
}
