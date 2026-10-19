import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/exceptions/income_exceptions.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubIncomeRepository implements IncomeRepository {
  Income? lastAdded;

  @override
  Future<void> addIncome(Income income) async => lastAdded = income;

  @override
  Future<List<Income>> getIncomes() async => [];

  @override
  Future<void> updateIncome(Income income) async {}

  @override
  Future<void> deleteIncome(String id) async {}

  @override
  Future<void> clearAll() async {}
}

void main() {
  late _StubIncomeRepository repository;
  late AddIncomeUseCase useCase;

  setUp(() {
    repository = _StubIncomeRepository();
    useCase = AddIncomeUseCase(repository, const Uuid());
  });

  group('AddIncomeUseCase — optional description', () {
    test('accepts empty description and stores trimmed', () async {
      await useCase(
        AddIncomeParams(
          amount: '100',
          description: '  ',
          date: DateTime(2024, 1, 15),
        ),
      );
      expect(repository.lastAdded?.description, '');
    });
  });

  group('AddIncomeUseCase — amount validation (ARCH-01)', () {
    test(
      'throws IncomeValidationException(invalidAmount) for non-numeric amount',
      () {
        expect(
          () async => useCase(
            AddIncomeParams(
              amount: 'abc',
              description: 'Test income',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<IncomeValidationException>().having(
              (e) => e.error,
              'error',
              IncomeValidationError.invalidAmount,
            ),
          ),
        );
      },
    );

    test(
      'throws IncomeValidationException(invalidAmount) for zero amount',
      () {
        expect(
          () async => useCase(
            AddIncomeParams(
              amount: '0',
              description: 'Test income',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<IncomeValidationException>().having(
              (e) => e.error,
              'error',
              IncomeValidationError.invalidAmount,
            ),
          ),
        );
      },
    );

    test('succeeds for valid amount', () async {
      await expectLater(
        useCase(
          AddIncomeParams(
            amount: '100',
            description: 'Test income',
            date: DateTime(2024, 1, 15),
          ),
        ),
        completes,
      );
    });
  });

  group('AddIncomeUseCase — UUID generation (ARCH-02)', () {
    test('generated income has non-empty id', () async {
      await useCase(
        AddIncomeParams(
          amount: '100',
          description: 'Test income',
          date: DateTime(2024, 1, 15),
        ),
      );
      expect(repository.lastAdded, isNotNull);
      expect(repository.lastAdded!.id, isNotEmpty);
    });
  });
}
