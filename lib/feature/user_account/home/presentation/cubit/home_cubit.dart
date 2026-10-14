import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/filter_criteria.dart';
import '../../domain/repositories/home_repository.dart';
import '../state/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(HomeRepository repository)
    : super(
        HomeState(
          categories: repository.getCategories(),
          filters: repository.getDefaultFilters(),
        ),
      );

  void selectTab(int index) {
    if (state.currentIndex == index) return;
    emit(state.copyWith(currentIndex: index));
  }

  void applyFilters(FilterCriteria filters) {
    emit(state.copyWith(filters: filters));
  }
}
