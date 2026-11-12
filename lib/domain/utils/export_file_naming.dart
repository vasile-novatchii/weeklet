/// Builds PDF file names. Names use a fixed English slug (not localized) and
/// contain no user-provided text.
class ExportFileNaming {
  const ExportFileNaming._();

  static const List<String> _months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];

  /// `<prefix>_<month>_<year>.pdf`, or `<prefix>_<year>.pdf` when [month] is
  /// null (whole year).
  static String reportFileName({
    required String prefix,
    required int year,
    int? month,
  }) {
    if (month == null) {
      return '${prefix}_$year.pdf';
    }
    return '${prefix}_${_months[month - 1]}_$year.pdf';
  }
}
