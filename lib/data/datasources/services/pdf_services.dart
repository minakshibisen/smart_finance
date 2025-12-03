import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formetter.dart';
import '../../../domain/entity/transactions.dart' as entity;


class PdfService {
  // Generate PDF for transactions
  Future<File> generateTransactionReport({
    required List<entity.Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> categoryData,
  }) async {
    final pdf = pw.Document();

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(),
          pw.SizedBox(height: 20),

          // Date Range
          _buildDateRange(startDate, endDate),
          pw.SizedBox(height: 20),

          // Summary Card
          _buildSummaryCard(totalIncome, totalExpense, balance),
          pw.SizedBox(height: 30),

          // Category Breakdown
          if (categoryData.isNotEmpty) ...[
            _buildSectionTitle('Category Breakdown'),
            pw.SizedBox(height: 10),
            _buildCategoryTable(categoryData),
            pw.SizedBox(height: 30),
          ],

          // Transactions List
          _buildSectionTitle('Transaction Details'),
          pw.SizedBox(height: 10),
          _buildTransactionTable(transactions),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/transaction_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Generate Monthly Report
  Future<File> generateMonthlyReport({
    required DateTime month,
    required List<entity.Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categorySpending,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(),
          pw.SizedBox(height: 20),

          // Month Title
          pw.Center(
            child: pw.Text(
              DateFormatter.getMonthYear(month),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary
          _buildSummaryCard(totalIncome, totalExpense, totalIncome - totalExpense),
          pw.SizedBox(height: 30),

          // Top Spending Categories
          if (categorySpending.isNotEmpty) ...[
            _buildSectionTitle('Top Spending Categories'),
            pw.SizedBox(height: 10),
            _buildCategoryTable(categorySpending),
            pw.SizedBox(height: 30),
          ],

          // All Transactions
          _buildSectionTitle('All Transactions (${transactions.length})'),
          pw.SizedBox(height: 10),
          _buildTransactionTable(transactions),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/monthly_report_${month.year}_${month.month}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Header
  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Smart Finance',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Transaction Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            'Generated on\n${DateFormatter.formatDateTime(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }

  // Date Range
  pw.Widget _buildDateRange(DateTime startDate, DateTime endDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Period: ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${DateFormatter.format(startDate)} - ${DateFormatter.format(endDate)}',
          ),
        ],
      ),
    );
  }

  // Summary Card
  pw.Widget _buildSummaryCard(
      double totalIncome,
      double totalExpense,
      double balance,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total Income',
            totalIncome,
            PdfColors.green600,
          ),
          _buildSummaryItem(
            'Total Expense',
            totalExpense,
            PdfColors.red600,
          ),
          _buildSummaryItem(
            'Balance',
            balance,
            balance >= 0 ? PdfColors.green600 : PdfColors.red600,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, double amount, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          CurrencyFormatter.format(amount),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Section Title
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.blue900,
            width: 2,
          ),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  // Category Table
  pw.Widget _buildCategoryTable(Map<String, double> categoryData) {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('Percentage', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        // Data rows
        ...sortedEntries.take(10).map((entry) {
          final total = sortedEntries.fold<double>(
            0,
                (sum, e) => sum + e.value,
          );
          final percentage = (entry.value / total * 100).toStringAsFixed(1);

          return pw.TableRow(
            children: [
              _buildTableCell(entry.key),
              _buildTableCell(
                CurrencyFormatter.formatWithoutDecimals(entry.value),
                align: pw.TextAlign.right,
              ),
              _buildTableCell('$percentage%', align: pw.TextAlign.right),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Transaction Table
  pw.Widget _buildTransactionTable(List<entity.Transaction> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Type', isHeader: true),
            _buildTableCell('Amount', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        // Data rows
        ...transactions.take(50).map((transaction) {
          final isIncome = transaction?.type == entity.TransactionType.income;
          return pw.TableRow(
            children: [
              _buildTableCell(DateFormatter.format(transaction.date)),
              _buildTableCell(transaction.category),
              _buildTableCell(
                isIncome ? 'Income' : 'Expense',
                color: isIncome ? PdfColors.green600 : PdfColors.red600,
              ),
              _buildTableCell(
                '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatWithoutDecimals(transaction.amount)}',
                align: pw.TextAlign.right,
                color: isIncome ? PdfColors.green600 : PdfColors.red600,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(
      String text, {
        bool isHeader = false,
        pw.TextAlign align = pw.TextAlign.left,
        PdfColor? color,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.grey900 : PdfColors.grey800),
        ),
        textAlign: align,
      ),
    );
  }

  // Footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  // Share PDF
  Future<void> sharePdf(File file, String subject) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: 'Transaction Report from Smart Finance',
    );
  }

  // Preview PDF
  Future<void> previewPdf(File file) async {
    await Printing.layoutPdf(
      onLayout: (format) async => file.readAsBytes(),
    );
  }

  // Print PDF
  Future<void> printPdf(File file) async {
    await Printing.layoutPdf(
      onLayout: (format) async => file.readAsBytes(),
    );
  }
}