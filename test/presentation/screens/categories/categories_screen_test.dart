import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/screens/categories/categories_screen.dart';
import 'package:weeklet/presentation/screens/categories/widgets/categories_empty_view.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_data.dart';

// MockCategoryBloc implements CategoryBloc so it can be assigned to
// BlocProvider<CategoryBloc>.value(). CategoryState is NOT Equatable —
// use when(() => mock.state).thenReturn(...) rather than equality matchers.
class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

void main() {
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockCategoryBloc.state).thenReturn(const CategoryLoading());
    whenListen(
      mockCategoryBloc,
      const Stream<CategoryState>.empty(),
      initialState: const CategoryLoading(),
    );

    // CategoryItemView calls sl<CategoryBloc>() only in _deleteCategory —
    // register the mock so GetIt can supply it if a delete is triggered.
    GetIt.instance.registerSingleton<CategoryBloc>(mockCategoryBloc);
  });

  tearDown(() async => GetIt.instance.reset());

  Future<void> pumpCategoriesScreen(WidgetTester tester) => pumpApp(
    tester,
    const CategoriesScreen(),
    providers: [
      BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
    ],
  );

  group('CategoriesScreen', () {
    testWidgets(
      'shows CircularProgressIndicator when state is CategoryLoading',
      (tester) async {
        await pumpCategoriesScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows category grid when CategoriesLoaded with categories',
      (tester) async {
        final loadedState = CategoriesLoaded(
          categories: [fakeCategory()],
        );
        when(() => mockCategoryBloc.state).thenReturn(loadedState);
        whenListen(
          mockCategoryBloc,
          Stream.value(loadedState),
          initialState: loadedState,
        );

        await pumpCategoriesScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Food'), findsOneWidget);
      },
    );

    testWidgets(
      'shows CategoriesEmptyView when CategoriesLoaded with empty list',
      (tester) async {
        const emptyState = CategoriesLoaded(categories: []);
        when(() => mockCategoryBloc.state).thenReturn(emptyState);
        whenListen(
          mockCategoryBloc,
          Stream.value(emptyState),
          initialState: emptyState,
        );

        await pumpCategoriesScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(CategoriesEmptyView), findsOneWidget);
      },
    );
  });
}
