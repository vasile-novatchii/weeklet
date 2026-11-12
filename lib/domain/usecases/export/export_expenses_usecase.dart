import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:weeklet/core/platform/export_file_store.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/export/transaction_pdf_labels.dart';
import 'package:weeklet/domain/utils/export_file_naming.dart';

class ExportExpensesParams {
  const ExportExpensesParams({
    required this.expenses,
    required this.categories,
    required this.currencySymbol,
    required this.year,
    required this.localeCode,
    required this.labels,
    required this.regularFont,
    required this.boldFont,
    this.month,
  });

  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;
  final int year;

  /// Null means the whole year (all months).
  final int? month;
  final String localeCode;
  final TransactionPdfLabels labels;
  final ByteData regularFont;
  final ByteData boldFont;
}

class ExportExpensesUseCase implements UseCase<String, ExportExpensesParams> {
  const ExportExpensesUseCase();

  @override
  Future<String> call(ExportExpensesParams params) async {
    await initializeDateFormatting(params.localeCode);

    final expenses = params.expenses;
    final currencySymbol = params.currencySymbol;
    final year = params.year;
    final month = params.month;
    final labels = params.labels;
    final localeCode = params.localeCode;

    final categoryMap = {for (final c in params.categories) c.id: c.name};
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    // Colors
    const headerColor = PdfColor.fromInt(0xFF1447E6);
    const tableHeaderFill = PdfColor.fromInt(0xFFF2F2F5);
    const tableHeaderText = PdfColor.fromInt(0xFF030213);
    const bodyText = PdfColor.fromInt(0xFF262626);
    const dividerColor = PdfColor.fromInt(0xFFE6E6E6);
    const evenRow = PdfColor.fromInt(0xFFFAFAFA);
    const oddRow = PdfColors.white;
    const mutedColor = PdfColor.fromInt(0xFF878B93);
    const totalsColor = PdfColor.fromInt(0xFF1447E6);

    final regularFont = pw.Font.ttf(params.regularFont);
    final boldFont = pw.Font.ttf(params.boldFont);

    final generatedFormatter = DateFormat('d MMMM yyyy', localeCode);
    final rowDateFormatter = DateFormat('dd MMM yyyy', localeCode);

    var period = month == null
        ? '$year'
        : DateFormat.yMMMM(localeCode).format(DateTime(year, month));
    if (period.isNotEmpty) {
      period = period[0].toUpperCase() + period.substring(1);
    }
    final generatedDate = generatedFormatter.format(DateTime.now());

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (pw.Context context) => [
          // Section 1: Header block
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 24,
            ),
            decoration: const pw.BoxDecoration(color: headerColor),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Weeklet',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${labels.reportTitleExpenses} · $period',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${labels.generatedLabel}: $generatedDate',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          // Section 2: Summary row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            decoration: const pw.BoxDecoration(color: tableHeaderFill),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${labels.recordsLabel}: ${expenses.length}',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: bodyText,
                  ),
                ),
                pw.Text(
                  '${labels.totalLabel}: '
                  '${NumberFormatter.formatCurrency(total, currencySymbol)}',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: bodyText,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          // Section 3: Data table or empty state
          if (expenses.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Text(
                  '${labels.noRecordsLabel} $period',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
              ),
            )
          else ...[
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(18),
                1: pw.FlexColumnWidth(22),
                2: pw.FlexColumnWidth(38),
                3: pw.FlexColumnWidth(22),
              },
              children: [
                // Header row
                pw.TableRow(
                  repeat: true,
                  decoration: const pw.BoxDecoration(color: tableHeaderFill),
                  children:
                      [
                            labels.columnDate,
                            labels.columnCategory,
                            labels.columnDescription,
                            labels.columnAmount,
                          ]
                          .asMap()
                          .entries
                          .map(
                            (entry) => pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              child: pw.Text(
                                entry.value,
                                textAlign: entry.key == 3
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left,
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 11,
                                  color: tableHeaderText,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                // Body rows
                ...expenses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final expense = entry.value;
                  final rowColor = index.isOdd ? evenRow : oddRow;
                  final categoryName =
                      categoryMap[expense.categoryId] ??
                      labels.unknownCategoryLabel;
                  final dateStr = rowDateFormatter.format(expense.createdAt);
                  final amountStr = NumberFormatter.formatCurrency(
                    expense.amount,
                    currencySymbol,
                  );

                  pw.Widget cell(String text, {bool right = false}) =>
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 4,
                        ),
                        child: pw.Text(
                          text,
                          textAlign: right
                              ? pw.TextAlign.right
                              : pw.TextAlign.left,
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: bodyText,
                          ),
                        ),
                      );

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: rowColor,
                      border: const pw.Border(
                        bottom: pw.BorderSide(
                          color: dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    children: [
                      cell(dateStr),
                      cell(categoryName),
                      cell(expense.description),
                      cell(amountStr, right: true),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 4),
            // Section 4: Totals row
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 4,
              ),
              decoration: const pw.BoxDecoration(color: totalsColor),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.totalLabel,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    NumberFormatter.formatCurrency(total, currencySymbol),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = ExportFileNaming.reportFileName(
      prefix: 'weeklet_expenses',
      year: year,
      month: month,
    );
    return ExportFileStore.write(fileName, bytes);
  }
}
