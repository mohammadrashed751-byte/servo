import '../../domain/entities/filter_criteria.dart';
import '../../domain/entities/home_category.dart';

class HomeState {
  final List<HomeCategory> categories;
  final FilterCriteria filters;
  final int currentIndex;

  HomeState({
    required List<HomeCategory> categories,
    required this.filters,
    this.currentIndex = 0,
  }) : categories = List.unmodifiable(categories);

  HomeState._({
    required this.categories,
    required this.filters,
    required this.currentIndex,
  });

  HomeState copyWith({FilterCriteria? filters, int? currentIndex}) =>
      HomeState._(
        categories: categories,
        filters: filters ?? this.filters,
        currentIndex: currentIndex ?? this.currentIndex,
      );
}
