import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servo/feature/home/data/datasources/home_local_data_source.dart';
import 'package:servo/feature/home/data/models/service_filters.dart';
import 'package:servo/feature/home/data/repositories/home_repository_impl.dart';
import 'package:servo/feature/home/domain/entities/filter_criteria.dart';
import 'package:servo/feature/home/presentation/cubit/home_cubit.dart';
import 'package:servo/feature/home/presentation/screen/categories_screen.dart';
import 'package:servo/feature/home/presentation/state/home_state.dart';
import 'package:servo/feature/home/presentation/widgets/category_icon.dart';
import 'package:servo/feature/home/presentation/widgets/filter_bottom_sheet.dart';

const _repository = HomeRepositoryImpl(HomeLocalDataSource());

void main() {
  test('local catalog keeps the existing order, labels and icons', () {
    final categories = _repository.getCategories();
    expect(categories.map((category) => category.title), [
      'IT Services',
      'Design',
      'Marketing',
      'Technology',
      'Cleaning',
      'Repairs',
    ]);
    expect(categories.map((category) => category.icon), [
      Icons.code,
      Icons.design_services_outlined,
      Icons.rss_feed,
      Icons.memory,
      Icons.cleaning_services,
      Icons.build,
    ]);
    expect(() => categories.clear(), throwsUnsupportedError);
  });

  test('filter model maps every value to the pure domain entity', () {
    final filters = const ServiceFilters(
      category: 'Design',
      minPrice: 50,
      maxPrice: 200,
    ).toEntity();
    expect(filters.category, 'Design');
    expect(filters.minPrice, 50);
    expect(filters.maxPrice, 200);
    expect(filters.isActive, isTrue);
    expect(_repository.getDefaultFilters().isActive, isFalse);
  });

  test('tab and applied filters preserve each other and the catalog', () async {
    final cubit = HomeCubit(_repository);
    addTearDown(cubit.close);
    final categories = cubit.state.categories;
    final emitted = <HomeState>[];
    final subscription = cubit.stream.listen(emitted.add);
    addTearDown(subscription.cancel);
    cubit.selectTab(2);
    cubit.selectTab(2);
    const filters = FilterCriteria(
      category: 'Design',
      minPrice: 50,
      maxPrice: 200,
    );
    cubit.applyFilters(filters);
    await Future<void>.delayed(Duration.zero);
    expect(emitted.length, 2);
    expect(cubit.state.currentIndex, 2);
    expect(cubit.state.filters, same(filters));
    expect(cubit.state.categories, same(categories));
    cubit.applyFilters(const FilterCriteria());
    expect(cubit.state.filters.category, isNull);
    expect(cubit.state.filters.isActive, isFalse);
    expect(cubit.state.currentIndex, 2);
  });

  testWidgets('filter changes are discarded when the sheet is dismissed', (
    tester,
  ) async {
    final cubit = await _pumpFilterHarness(tester);
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design'));
    await tester.enterText(find.byType(TextFormField).first, '50');
    final sheetContext = tester.element(find.byType(FilterBottomSheet));
    Navigator.of(sheetContext).pop();
    await tester.pumpAndSettle();
    expect(cubit.state.filters.isActive, isFalse);
  });

  testWidgets(
    'apply saves values, reopening restores them, reset needs apply',
    (tester) async {
      final cubit = await _pumpFilterHarness(tester);
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Design'));
      await tester.enterText(find.byType(TextFormField).first, '50');
      await tester.enterText(find.byType(TextFormField).last, '200');
      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();
      expect(cubit.state.filters.category, 'Design');
      expect(cubit.state.filters.minPrice, 50);
      expect(cubit.state.filters.maxPrice, 200);
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
        const RangeValues(50, 200),
      );
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(cubit.state.filters.category, 'Design');
      expect(
        tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
        const RangeValues(0, 250),
      );
      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();
      expect(cubit.state.filters.isActive, isFalse);
    },
  );

  testWidgets(
    'invalid prices block apply and slider edits synchronize fields',
    (tester) async {
      final cubit = await _pumpFilterHarness(tester);
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Apply Filter'));
      await tester.pump();
      expect(find.text('Enter a price'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '220');
      await tester.enterText(find.byType(TextFormField).last, '200');
      await tester.pump();
      expect(find.text('Min must be ≤ max'), findsOneWidget);
      expect(cubit.state.filters.isActive, isFalse);
      tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
        const RangeValues(50, 200),
      );
      await tester.pump();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '50',
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).last)
            .controller!
            .text,
        '200',
      );
      expect(find.text('Min must be ≤ max'), findsNothing);
    },
  );

  testWidgets(
    'categories keep case-insensitive trimmed search and empty result',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CategoriesScreen(categories: _repository.getCategories()),
        ),
      );
      await tester.enterText(find.byType(TextField), '  DESIGN  ');
      await tester.pump();
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('IT Services'), findsNothing);
      await tester.enterText(find.byType(TextField), 'unknown');
      await tester.pump();
      expect(find.text('No categories found'), findsOneWidget);
    },
  );
}

Future<HomeCubit> _pumpFilterHarness(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final cubit = HomeCubit(_repository);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final result = await showModalBottomSheet<FilterCriteria>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FilterBottomSheet(
                      initialFilters: cubit.state.filters,
                      categoryNames: cubit.state.categories
                          .map((category) => category.title)
                          .toList(),
                    ),
                  );
                  if (result != null) cubit.applyFilters(result);
                },
                child: const Text('Open filters'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return cubit;
}
