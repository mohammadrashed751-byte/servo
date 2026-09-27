import 'package:flutter/material.dart';

import '../../domain/entities/home_category.dart';

extension HomeCategoryIcon on HomeCategory {
  IconData get icon => switch (type) {
    HomeCategoryType.itServices => Icons.code,
    HomeCategoryType.design => Icons.design_services_outlined,
    HomeCategoryType.marketing => Icons.rss_feed,
    HomeCategoryType.technology => Icons.memory,
    HomeCategoryType.cleaning => Icons.cleaning_services,
    HomeCategoryType.repairs => Icons.build,
  };
}
