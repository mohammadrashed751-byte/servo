import '../../domain/entities/filter_criteria.dart';

class ServiceFilters {
  final String? category;
  final double minPrice;
  final double maxPrice;

  const ServiceFilters({
    this.category,
    this.minPrice = FilterCriteria.lowestPrice,
    this.maxPrice = FilterCriteria.highestPrice,
  });

  FilterCriteria toEntity() => FilterCriteria(
    category: category,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );
}
