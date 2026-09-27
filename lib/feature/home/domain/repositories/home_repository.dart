import '../entities/filter_criteria.dart';
import '../entities/home_category.dart';

abstract class HomeRepository {
  List<HomeCategory> getCategories();
  FilterCriteria getDefaultFilters();
}
