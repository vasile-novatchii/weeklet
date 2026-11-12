import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/usecases/export/build_export_subject_usecase.dart';

void main() {
  const useCase = BuildExportSubjectUseCase();

  test('month export uses localized capitalized month and year', () async {
    final subject = await useCase(
      const BuildExportSubjectParams(
        reportTitle: 'Statistics Report',
        localeCode: 'en',
        year: 2026,
        month: 3,
      ),
    );
    expect(subject, 'Weeklet Statistics Report - March 2026');
  });

  test('annual export uses the year only', () async {
    final subject = await useCase(
      const BuildExportSubjectParams(
        reportTitle: 'Statistics Report',
        localeCode: 'en',
        year: 2025,
        month: null,
      ),
    );
    expect(subject, 'Weeklet Statistics Report - 2025');
  });

  test('capitalizes lowercase localized month names', () async {
    final subject = await useCase(
      const BuildExportSubjectParams(
        reportTitle: 'Raport',
        localeCode: 'ro',
        year: 2026,
        month: 3,
      ),
    );
    expect(subject, startsWith('Weeklet Raport - M'));
  });
}
