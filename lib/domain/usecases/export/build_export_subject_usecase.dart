import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class BuildExportSubjectParams {
  const BuildExportSubjectParams({
    required this.reportTitle,
    required this.localeCode,
    required this.year,
    required this.month,
  });

  final String reportTitle;
  final String localeCode;
  final int year;

  /// Null means the whole year.
  final int? month;
}

/// Builds the share subject for an exported PDF:
/// `Weeklet <report title> - <period>`, where the period is the localized
/// month name and year (or the year alone), first letter capitalized.
class BuildExportSubjectUseCase
    implements UseCase<String, BuildExportSubjectParams> {
  const BuildExportSubjectUseCase();

  @override
  Future<String> call(BuildExportSubjectParams params) async {
    await initializeDateFormatting(params.localeCode);
    final month = params.month;
    var period = month == null
        ? '${params.year}'
        : DateFormat.yMMMM(
            params.localeCode,
          ).format(DateTime(params.year, month));
    if (period.isNotEmpty) {
      period = period[0].toUpperCase() + period.substring(1);
    }
    return 'Weeklet ${params.reportTitle} - $period';
  }
}
