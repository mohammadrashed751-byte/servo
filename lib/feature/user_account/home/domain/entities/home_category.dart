enum HomeCategoryType {
  itServices,
  design,
  marketing,
  technology,
  cleaning,
  repairs,
}

class HomeCategory {
  final HomeCategoryType type;
  final String title;
  final int? id;

  const HomeCategory({required this.type, required this.title, this.id});
}
