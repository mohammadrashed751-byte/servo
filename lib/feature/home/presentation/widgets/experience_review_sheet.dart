import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ExperienceReviewSheet extends StatefulWidget {
  const ExperienceReviewSheet({super.key});

  @override
  State<ExperienceReviewSheet> createState() => _ExperienceReviewSheetState();
}

class _ExperienceReviewSheetState extends State<ExperienceReviewSheet> {
  int? _selectedRating;
  String _review = '';

  final List<String> _emojis = ['😢', '🙁', '😐', '😁', '😍'];

  final List<String> _ratingLabels = [
    'Very poor',
    'Poor',
    'Average',
    'Good',
    'Excellent',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: responsiveWidth(context, 24),
        right: responsiveWidth(context, 24),
        top: responsiveHeight(context, 12),
        bottom:
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            responsiveHeight(context, 24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How was your Experience?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          SizedBox(height: responsiveHeight(context, 12)),

          Text(
            'Do you mind giving us some feedback '
            'about your experience?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),

          SizedBox(height: responsiveHeight(context, 28)),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: List.generate(_emojis.length, (index) {
                final rating = index + 1;
                final isSelected = _selectedRating == rating;

                return Expanded(
                  child: Semantics(
                    selected: isSelected,
                    child: IconButton(
                      tooltip: _ratingLabels[index],
                      onPressed: () {
                        setState(() {
                          _selectedRating = rating;
                        });
                      },
                      icon: AnimatedScale(
                        scale: isSelected ? 1.25 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _emojis[index],
                          style: TextStyle(
                            fontSize: 26,
                            shadows: isSelected
                                ? [
                                    Shadow(
                                      color: Colors.black.withAlpha(55),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: responsiveHeight(context, 24)),

          const Divider(color: AppColors.border),

          SizedBox(height: responsiveHeight(context, 16)),

          Text(
            'WRITE A REVIEW',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: responsiveHeight(context, 10)),

          TextField(
            minLines: 4,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              _review = value;
            },
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Type here...',
              hintStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),

          SizedBox(height: responsiveHeight(context, 24)),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),

              SizedBox(width: responsiveWidth(context, 12)),

              Expanded(
                child: FilledButton(
                  onPressed: _selectedRating == null
                      ? null
                      : () {
                          Navigator.pop(context, <String, Object>{
                            'rating': _selectedRating!,
                            'review': _review.trim(),
                          });
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
