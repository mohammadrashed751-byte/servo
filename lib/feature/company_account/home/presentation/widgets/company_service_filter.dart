import 'package:flutter/material.dart';
import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';

enum CompanyServiceStatus {
  pending('Inactive'),
  accepted('Active'),
  completed('Completed');

  const CompanyServiceStatus(this.label);
  final String label;
}

class CompanyServiceFilter {
  const CompanyServiceFilter({this.category, this.status});

  final String? category;
  final CompanyServiceStatus? status;
  bool get isActive => category != null || status != null;
}

class CompanyServiceFilterSheet extends StatefulWidget {
  const CompanyServiceFilterSheet({
    super.key,
    required this.initialFilter,
    this.categories = const [],
  });

  final CompanyServiceFilter initialFilter;
  final List<String> categories;

  @override
  State<CompanyServiceFilterSheet> createState() =>
      _CompanyServiceFilterSheetState();
}

class _CompanyServiceFilterSheetState extends State<CompanyServiceFilterSheet> {
  late String? _category = widget.initialFilter.category;
  late CompanyServiceStatus? _status = widget.initialFilter.status;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          responsiveWidth(context, 32),
          responsiveHeight(context, 12),
          responsiveWidth(context, 32),
          responsiveHeight(context, 28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Filter',
                style: AppTextStyles.textTheme.headlineLarge,
              ),
            ),
            SizedBox(height: responsiveHeight(context, 40)),
            Text('Categories', style: AppTextStyles.textTheme.headlineSmall),
            SizedBox(height: responsiveHeight(context, 16)),
            Wrap(
              spacing: responsiveWidth(context, 10),
              runSpacing: responsiveHeight(context, 8),
              children: [
                for (final category in widget.categories)
                  _chip(context, category, _category == category, () {
                    setState(
                      () => _category = _category == category ? null : category,
                    );
                  }),
              ],
            ),
            SizedBox(height: responsiveHeight(context, 30)),
            Text('Status', style: AppTextStyles.textTheme.headlineSmall),
            SizedBox(height: responsiveHeight(context, 16)),
            Wrap(
              spacing: responsiveWidth(context, 10),
              runSpacing: responsiveHeight(context, 8),
              children: [
                for (final status in [
                  CompanyServiceStatus.pending,
                  CompanyServiceStatus.accepted,
                ])
                  _chip(context, status.label, _status == status, () {
                    setState(() => _status = _status == status ? null : status);
                  }),
              ],
            ),
            SizedBox(height: responsiveHeight(context, 48)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(
                        0,
                        responsiveHeight(context, 60).clamp(48, 80).toDouble(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 16),
                        ),
                      ),
                    ),
                    onPressed: () => setState(() {
                      _category = null;
                      _status = null;
                    }),
                    child: const Text('Reset'),
                  ),
                ),
                SizedBox(width: responsiveWidth(context, 16)),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      minimumSize: Size(
                        0,
                        responsiveHeight(context, 60).clamp(48, 80).toDouble(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 16),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(
                      context,
                      CompanyServiceFilter(
                        category: _category,
                        status: _status,
                      ),
                    ),
                    child: const Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(context, 10)),
      ),
      labelStyle: AppTextStyles.textTheme.bodySmall?.copyWith(
        color: selected ? AppColors.surface : AppColors.textSecondary,
      ),
    );
  }
}
