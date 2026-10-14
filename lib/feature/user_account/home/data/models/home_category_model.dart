import '../../domain/entities/home_category.dart';

class HomeCategoryModel {
  final HomeCategoryType type;
  final String title;

  const HomeCategoryModel({required this.type, required this.title});

  HomeCategory toEntity() => HomeCategory(type: type, title: title);
}
