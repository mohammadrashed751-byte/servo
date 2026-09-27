import '../../domain/entities/filter_criteria.dart';
import '../../domain/entities/home_category.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource dataSource;

  const HomeRepositoryImpl(this.dataSource);

  @override
  List<HomeCategory> getCategories() => List<HomeCategory>.unmodifiable(
    dataSource.getCategories().map((model) => model.toEntity()),
  );

  @override
  FilterCriteria getDefaultFilters() =>
      dataSource.getDefaultFilters().toEntity();
}
