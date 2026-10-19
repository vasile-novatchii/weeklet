import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/utils/default_category_selection.dart';

Category _c(String id) =>
    Category(id: id, name: id, icon: 'home', createdAt: DateTime(2024));

void main() {
  group('DefaultCategorySelection.preselectedCategoryId', () {
    test('returns default id when it is the sole category', () {
      expect(
        DefaultCategorySelection.preselectedCategoryId([_c('a')], 'a'),
        'a',
      );
    });

    test('null for zero categories', () {
      expect(DefaultCategorySelection.preselectedCategoryId([], 'a'), isNull);
    });

    test('null for two or more categories', () {
      expect(
        DefaultCategorySelection.preselectedCategoryId(
          [_c('a'), _c('b')],
          'a',
        ),
        isNull,
      );
    });

    test('null for a sole non-default category', () {
      expect(
        DefaultCategorySelection.preselectedCategoryId([_c('b')], 'a'),
        isNull,
      );
    });

    test('null for a null default id', () {
      expect(
        DefaultCategorySelection.preselectedCategoryId([_c('a')], null),
        isNull,
      );
    });
  });
}
