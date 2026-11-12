import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:weeklet/core/platform/export_file_store.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';
import 'package:weeklet/domain/utils/stats_export_utils.dart';

class ExportStatsParams {
  const ExportStatsParams({
    required this.stats,
    required this.monthRows,
    required this.year,
    required this.month,
    required this.currencySymbol,
    required this.localeCode,
    required this.labels,
    required this.categoryColors,
    required this.regularFont,
    required this.boldFont,
    this.generatedAt,
  });

  final MonthlyStats stats;
  final List<MonthlySnapshot> monthRows;
  final int year;

  /// Null means the whole year (all months).
  final int? month;
  final String currencySymbol;
  final String localeCode;
  final StatsPdfLabels labels;

  /// Category id -> ARGB color value.
  final Map<String, int> categoryColors;
  final ByteData regularFont;
  final ByteData boldFont;
  final DateTime? generatedAt;
}

class ExportStatsUseCase implements UseCase<String, ExportStatsParams> {
  const ExportStatsUseCase();

  static const _headerColor = PdfColor.fromInt(0xFF1447E6);
  static const _tableHeaderFill = PdfColor.fromInt(0xFFF2F2F5);
  static const _tableHeaderText = PdfColor.fromInt(0xFF030213);
  static const _bodyText = PdfColor.fromInt(0xFF262626);
  static const _dividerColor = PdfColor.fromInt(0xFFE6E6E6);
  static const _evenRow = PdfColor.fromInt(0xFFFAFAFA);
  static const _oddRow = PdfColors.white;
  static const _mutedColor = PdfColor.fromInt(0xFF878B93);
  static const _totalsColor = PdfColor.fromInt(0xFF1447E6);

  @override
  Future<String> call(ExportStatsParams params) async {
    await initializeDateFormatting(params.localeCode);

    final regular = pw.Font.ttf(params.regularFont);
    final bold = pw.Font.ttf(params.boldFont);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (pw.Context context) => [
          _buildHeader(params),
          pw.SizedBox(height: 8),
          _buildSummary(params),
          pw.SizedBox(height: 8),
          ..._buildCategorySection(params),
          if (params.month == null && params.monthRows.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            ..._buildMonthSection(params),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    return ExportFileStore.write(
      StatsExportUtils.fileName(params.year, params.month),
      bytes,
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static pw.TextStyle _style({
    double size = 10,
    PdfColor color = _bodyText,
    bool isBold = false,
  }) => pw.TextStyle(
    fontSize: size,
    color: color,
    fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  pw.Widget _cell(
    String text, {
    bool right = false,
    bool header = false,
    PdfColor color = _bodyText,
  }) => pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: header ? 6 : 5, horizontal: 4),
    child: pw.Text(
      text,
      textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
      style: header
          ? _style(size: 11, color: _tableHeaderText, isBold: true)
          : _style(color: color),
    ),
  );

  pw.Widget _buildHeader(ExportStatsParams params) {
    final month = params.month;
    final period = month == null
        ? '${params.year}'
        : _cap(
            DateFormat.yMMMM(
              params.localeCode,
            ).format(DateTime(params.year, month)),
          );
    final generated = DateFormat(
      'd MMMM yyyy',
      params.localeCode,
    ).format(params.generatedAt ?? DateTime.now());

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const pw.BoxDecoration(color: _headerColor),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Weeklet',
            style: _style(size: 24, color: PdfColors.white, isBold: true),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${params.labels.reportTitle} · $period',
            style: _style(size: 14, color: PdfColors.white, isBold: true),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${params.labels.generatedLabel}: $generated',
            style: _style(size: 11, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {String? growth}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: _style(size: 11)),
            pw.Row(
              children: [
                if (growth != null) ...[
                  pw.Text(growth, style: _style(color: _mutedColor)),
                  pw.SizedBox(width: 8),
                ],
                pw.Text(value, style: _style(size: 11, isBold: true)),
              ],
            ),
          ],
        ),
      );

  pw.Widget _buildSummary(ExportStatsParams params) {
    final stats = params.stats;
    final sym = params.currencySymbol;
    final labels = params.labels;
    final isMonth = params.month != null;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const pw.BoxDecoration(color: _tableHeaderFill),
      child: pw.Column(
        children: [
          _summaryRow(
            labels.incomeLabel,
            NumberFormatter.formatCurrency(stats.totalIncome, sym),
            growth: isMonth
                ? '${StatsExportUtils.formatGrowth(stats.incomeGrowthPercentage)} ${labels.vsLastMonthLabel}'
                : null,
          ),
          _summaryRow(
            labels.expensesLabel,
            NumberFormatter.formatCurrency(stats.totalExpenses, sym),
            growth: isMonth
                ? '${StatsExportUtils.formatGrowth(stats.expenseGrowthPercentage)} ${labels.vsLastMonthLabel}'
                : null,
          ),
          _summaryRow(
            labels.balanceLabel,
            StatsExportUtils.formatBalance(stats.balance, sym),
          ),
        ],
      ),
    );
  }

  pw.Widget _totalsBar(List<String> cells) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    decoration: const pw.BoxDecoration(color: _totalsColor),
    child: pw.Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          pw.Expanded(
            flex: i == 0 ? 2 : 1,
            child: pw.Text(
              cells[i],
              textAlign: i == 0 ? pw.TextAlign.left : pw.TextAlign.right,
              style: _style(size: 11, color: PdfColors.white, isBold: true),
            ),
          ),
      ],
    ),
  );

  pw.TableRow _bodyRow(int index, List<pw.Widget> children) => pw.TableRow(
    decoration: pw.BoxDecoration(
      color: index.isOdd ? _evenRow : _oddRow,
      border: const pw.Border(
        bottom: pw.BorderSide(color: _dividerColor, width: 0.5),
      ),
    ),
    children: children,
  );

  pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(title, style: _style(size: 13, isBold: true)),
  );

  List<pw.Widget> _buildCategorySection(ExportStatsParams params) {
    final stats = params.stats;
    final sym = params.currencySymbol;
    final labels = params.labels;
    final out = <pw.Widget>[_sectionTitle(labels.categoryBreakdownTitle)];

    if (stats.categoryStats.isEmpty) {
      out.add(
        pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Text(
              labels.noExpensesLabel,
              style: _style(size: 12, color: _mutedColor),
            ),
          ),
        ),
      );
      return out;
    }

    out
      ..add(
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(50),
            1: pw.FlexColumnWidth(30),
            2: pw.FlexColumnWidth(20),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _tableHeaderFill),
              children: [
                _cell(labels.columnCategory, header: true),
                _cell(labels.columnAmount, header: true, right: true),
                _cell(labels.columnShare, header: true, right: true),
              ],
            ),
            for (var i = 0; i < stats.categoryStats.length; i++)
              _bodyRow(i, [
                _categoryCell(params, stats.categoryStats[i]),
                _cell(
                  NumberFormatter.formatCurrency(
                    stats.categoryStats[i].totalAmount,
                    sym,
                  ),
                  right: true,
                ),
                _cell(
                  StatsExportUtils.formatShare(
                    stats.categoryStats[i].percentage,
                  ),
                  right: true,
                ),
              ]),
          ],
        ),
      )
      ..add(pw.SizedBox(height: 4))
      ..add(
        _totalsBar([
          labels.totalLabel,
          NumberFormatter.formatCurrency(stats.totalExpenses, sym),
        ]),
      );
    return out;
  }

  pw.Widget _categoryCell(ExportStatsParams params, CategoryStats stat) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Row(
          children: [
            pw.Container(
              width: 8,
              height: 8,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(
                  params.categoryColors[stat.category.id] ?? 0xFF878B93,
                ),
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(child: pw.Text(stat.category.name, style: _style())),
          ],
        ),
      );

  List<pw.Widget> _buildMonthSection(ExportStatsParams params) {
    final labels = params.labels;
    final sym = params.currencySymbol;
    final rows = params.monthRows;
    var income = 0.0;
    var expenses = 0.0;
    var balance = 0.0;
    for (final r in rows) {
      income += r.totalIncome;
      expenses += r.totalExpenses;
      balance += r.balance;
    }
    final monthFormat = DateFormat('LLLL', params.localeCode);

    return [
      _sectionTitle(labels.monthBreakdownTitle),
      pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _tableHeaderFill),
            children: [
              _cell(labels.columnMonth, header: true),
              _cell(labels.columnIncome, header: true, right: true),
              _cell(labels.columnExpenses, header: true, right: true),
              _cell(labels.columnBalance, header: true, right: true),
            ],
          ),
          for (var i = 0; i < rows.length; i++)
            _bodyRow(i, [
              _cell(
                _cap(monthFormat.format(DateTime(params.year, rows[i].month))),
              ),
              _cell(
                NumberFormatter.formatCurrency(rows[i].totalIncome, sym),
                right: true,
              ),
              _cell(
                NumberFormatter.formatCurrency(rows[i].totalExpenses, sym),
                right: true,
              ),
              _cell(
                StatsExportUtils.formatBalance(rows[i].balance, sym),
                right: true,
              ),
            ]),
        ],
      ),
      pw.SizedBox(height: 4),
      _totalsBar([
        labels.totalLabel,
        NumberFormatter.formatCurrency(income, sym),
        NumberFormatter.formatCurrency(expenses, sym),
        StatsExportUtils.formatBalance(balance, sym),
      ]),
    ];
  }
}
