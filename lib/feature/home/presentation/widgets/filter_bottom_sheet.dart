import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/filter_criteria.dart';
import 'price_field.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterCriteria initialFilters;
  final List<String> categoryNames;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.categoryNames,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late String? _category;
  late RangeValues _range;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialFilters.category;
    _range = RangeValues(
      widget.initialFilters.minPrice,
      widget.initialFilters.maxPrice,
    );
    _minController = TextEditingController(
      text: _range.start.toStringAsFixed(0),
    );
    _maxController = TextEditingController(text: _range.end.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? text, {required bool isMinimum}) {
    final value = double.tryParse(text ?? '');
    if (value == null) return 'Enter a price';
    if (value < FilterCriteria.lowestPrice ||
        value > FilterCriteria.highestPrice) {
      return 'Use 0–250 JD';
    }
    final maximum = double.tryParse(_maxController.text);
    if (isMinimum && maximum != null && value > maximum) {
      return 'Min must be ≤ max';
    }
    return null;
  }

  void _syncFromFields(String _) {
    final min = double.tryParse(_minController.text);
    final max = double.tryParse(_maxController.text);
    if (min != null &&
        max != null &&
        min >= FilterCriteria.lowestPrice &&
        max <= FilterCriteria.highestPrice &&
        min <= max) {
      setState(() => _range = RangeValues(min, max));
    }
    if (_submitted) _formKey.currentState?.validate();
  }

  void _setRange(RangeValues values) {
    setState(() {
      _range = values;
      _minController.text = values.start.toStringAsFixed(0);
      _maxController.text = values.end.toStringAsFixed(0);
    });
    if (_submitted) _formKey.currentState?.validate();
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    setState(() {
      _submitted = false;
      _category = null;
    });
    _setRange(
      const RangeValues(
        FilterCriteria.lowestPrice,
        FilterCriteria.highestPrice,
      ),
    );
  }

  void _apply() {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      FilterCriteria(
        category: _category,
        minPrice: double.parse(_minController.text),
        maxPrice: double.parse(_maxController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Filter',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Categories',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.categoryNames.toSet().map((name) {
                    final selected = _category == name;
                    return ChoiceChip(
                      label: Text(name),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: textTheme.bodySmall?.copyWith(
                        color: selected
                            ? AppColors.surface
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      onSelected: (value) => setState(() {
                        _category = value ? name : null;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Text(
                  'Price',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PriceField(
                        controller: _minController,
                        label: 'Min price',
                        onChanged: _syncFromFields,
                        validator: (value) =>
                            _validatePrice(value, isMinimum: true),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: PriceField(
                        controller: _maxController,
                        label: 'Max price',
                        onChanged: _syncFromFields,
                        validator: (value) =>
                            _validatePrice(value, isMinimum: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 3),
                  child: RangeSlider(
                    values: _range,
                    min: FilterCriteria.lowestPrice,
                    max: FilterCriteria.highestPrice,
                    divisions: 250,
                    activeColor: AppColors.primary,
                    inactiveColor: const Color(0xFFE8EEFF),
                    labels: RangeLabels(
                      '${_range.start.toStringAsFixed(0)} JD',
                      '${_range.end.toStringAsFixed(0)} JD',
                    ),
                    onChangeStart: (_) => FocusScope.of(context).unfocus(),
                    onChanged: _setRange,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MIN',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'MAX',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _apply,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
        ),
      ),
    );
  }
}
