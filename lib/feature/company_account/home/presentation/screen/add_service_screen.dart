import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:servo/core/theme/app_colors.dart';
import 'package:servo/core/theme/app_theme.dart';
import 'package:servo/core/utils/responsive.dart';

// البيانات التي يدخلها المستخدم في الفورم.
class NewServiceInput {
  const NewServiceInput({
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.description,
  });

  final String name;
  final String category;
  final int? durationMinutes;
  final double price;
  final String description;
}

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({
    super.key,
    this.onSave,
    this.initialInput,
    this.categories = const [],
  });

  // نمرر دالة الحفظ عندما نربط الشاشة بالـAPI.
  final Future<void> Function(NewServiceInput input)? onSave;
  final NewServiceInput? initialInput;
  final List<String> categories;

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  // تصنيفات مؤقتة للواجهة، نستبدلها بتصنيفات السيرفر عند الربط.
  @override
  void initState() {
    super.initState();
    final input = widget.initialInput;
    if (input != null) {
      _nameController.text = input.name;
      _selectedCategory = input.category;
      _durationController.text = input.durationMinutes?.toString() ?? '';
      _priceController.text = input.price.toString();
      _descriptionController.text = input.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final save = widget.onSave;

    if (save == null || _isSaving) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final input = NewServiceInput(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      durationMinutes: int.parse(_durationController.text.trim()),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
    );

    setState(() => _isSaving = true);

    try {
      await save(input);

      if (!mounted) return;

      // نرجع true حتى تعرف شاشة القائمة أن الحفظ نجح.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _decoration(
    String label, {
    Widget? suffixIcon,
    String? suffixText,
  }) {
    final radius = BorderRadius.circular(responsiveWidth(context, 20));

    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: AppTextStyles.textTheme.bodyMedium,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(context, 20),
        vertical: responsiveHeight(context, 20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.failed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.failed),
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle = AppTextStyles.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
    );

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: responsiveWidth(context, 24)),
          ),
          title: Text(
            widget.initialInput == null ? 'ADD Service' : 'Edit Service',
            style: AppTextStyles.textTheme.headlineMedium,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(context, 32),
                    vertical: responsiveHeight(context, 40),
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          enabled: !_isSaving,
                          style: fieldStyle,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration('Service Name'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the service name';
                            }
                            if (value.trim().length > 255) {
                              return 'Use 255 characters or fewer';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsiveHeight(context, 32)),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          style: fieldStyle,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          decoration: _decoration('Category'),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: responsiveWidth(context, 24),
                            color: AppColors.grey,
                          ),
                          items: widget.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Choose a category';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsiveHeight(context, 32)),
                        TextFormField(
                          controller: _durationController,
                          enabled: !_isSaving,
                          style: fieldStyle,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _decoration(
                            'Duration (minutes)',
                            suffixIcon: Icon(
                              Icons.schedule_rounded,
                              color: AppColors.textPrimary,
                              size: responsiveWidth(context, 22),
                            ),
                          ),
                          validator: (value) {
                            final duration = int.tryParse(value?.trim() ?? '');

                            if (duration == null || duration <= 0) {
                              return 'Enter a duration greater than zero';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsiveHeight(context, 32)),
                        TextFormField(
                          controller: _priceController,
                          enabled: !_isSaving,
                          style: fieldStyle,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: _decoration('Price', suffixText: 'JD'),
                          validator: (value) {
                            final price = double.tryParse(value?.trim() ?? '');

                            if (price == null || !price.isFinite || price < 0) {
                              return 'Enter a valid price, such as 25.50';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: responsiveHeight(context, 32)),
                        TextFormField(
                          controller: _descriptionController,
                          enabled: !_isSaving,
                          style: fieldStyle,
                          minLines: 2,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: _decoration('Description'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsiveWidth(context, 32),
                  responsiveHeight(context, 16),
                  responsiveWidth(context, 32),
                  responsiveHeight(context, 32),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving || widget.onSave == null
                        ? null
                        : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      minimumSize: Size(
                        double.infinity,
                        responsiveHeight(context, 64),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: responsiveHeight(context, 18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveWidth(context, 18),
                        ),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: responsiveWidth(context, 22),
                            height: responsiveWidth(context, 22),
                            child: const CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.initialInput == null
                                ? 'ADD Service'
                                : 'Save Changes',
                            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
