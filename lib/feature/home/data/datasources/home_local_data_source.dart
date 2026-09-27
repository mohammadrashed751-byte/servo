import '../../domain/entities/home_category.dart';
import '../models/home_category_model.dart';
import '../models/service_filters.dart';

class HomeLocalDataSource {
  const HomeLocalDataSource();

  List<HomeCategoryModel> getCategories() => const [
    HomeCategoryModel(type: HomeCategoryType.itServices, title: 'IT Services'),
    HomeCategoryModel(type: HomeCategoryType.design, title: 'Design'),
    HomeCategoryModel(type: HomeCategoryType.marketing, title: 'Marketing'),
    HomeCategoryModel(type: HomeCategoryType.technology, title: 'Technology'),
    HomeCategoryModel(type: HomeCategoryType.cleaning, title: 'Cleaning'),
    HomeCategoryModel(type: HomeCategoryType.repairs, title: 'Repairs'),
  ];

  ServiceFilters getDefaultFilters() => const ServiceFilters();
}
