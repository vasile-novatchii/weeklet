import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';

import 'test_data.dart';
import 'test_hive_env.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(registerHiveAdaptersOnce);

  group('test_hive_env', () {
    // Registering cleanup with tearDown (not calling it inline at the end of
    // each test body) guarantees it runs even when an expect() above throws —
    // otherwise a skipped teardownTestDi() leaks GetIt/Hive registrations into
    // the next test's initTestDi(), masking the real failure with a confusing
    // "already registered" error (WR-01).
    setUp(initTestDi);
    tearDown(teardownTestDi);

    test(
      'initTestDi registers a real CategoryRepository and round-trips a '
      'seeded category',
      () async {
        final repository = GetIt.instance<CategoryRepository>();
        await repository.addCategory(fakeCategory());

        final categories = await repository.getAllCategories();

        expect(categories.map((c) => c.id), contains(fakeCategory().id));
      },
    );

    test(
      'teardownTestDi followed by fresh initTestDi leaves no residue '
      '(isolation)',
      () async {
        final firstRepository = GetIt.instance<CategoryRepository>();
        await firstRepository.addCategory(fakeCategory(id: 'leak-check'));

        // Deliberate mid-test teardown/init pair to prove isolation; the
        // final cleanup is handled by tearDown() above.
        await teardownTestDi();
        await initTestDi();

        final secondRepository = GetIt.instance<CategoryRepository>();
        final categories = await secondRepository.getAllCategories();

        expect(categories, isEmpty);
      },
    );
  });
}
