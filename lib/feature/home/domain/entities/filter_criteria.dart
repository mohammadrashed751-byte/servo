class FilterCriteria {
  static const double lowestPrice = 0;
  static const double highestPrice = 250;

  final String? category;
  final double minPrice;
  final double maxPrice;

  const FilterCriteria({
    this.category,
    this.minPrice = lowestPrice,
    this.maxPrice = highestPrice,
  });

  bool get isActive =>
      category != null || minPrice != lowestPrice || maxPrice != highestPrice;
}
