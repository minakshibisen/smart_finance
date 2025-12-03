import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

import '../../../core/utils/date_formetter.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import '../../../data/datasources/services/pdf_services.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _firestoreService = FirestoreService();
  final _pdfService = PdfService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch data
      final transactions = await _firestoreService
          .getTransactionsByDateRange(
        startDate: _startDate,
        endDate: _endDate,
      )
          .first;

      final totalIncome = transactions
          .where((t) => t.type.toString().contains('income'))
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type.toString().contains('expense'))
          .fold<double>(0, (sum, t) => sum + t.amount);

      final categoryData = await _firestoreService.getCategoryWiseSpending();

      // Generate PDF
      final file = await _pdfService.generateTransactionReport(
        transactions: transactions,
        startDate: _startDate,
        endDate: _endDate,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        categoryData: categoryData,
      );

      setState(() {
        _isLoading = false;
      });

      // Show options
      _showPdfOptions(file);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _generateMonthlyReport(DateTime month) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final transactions = await _firestoreService
          .getTransactionsByDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
      )
          .first;

      final stats = await _firestoreService.getMonthlyStats(month);
      final categoryData = await _firestoreService.getCategoryWiseSpending();

      final file = await _pdfService.generateMonthlyReport(
        month: month,
        transactions: transactions,
        totalIncome: stats['income'] ?? 0,
        totalExpense: stats['expense'] ?? 0,
        categorySpending: categoryData,
      );

      setState(() {
        _isLoading = false;
      });

      _showPdfOptions(file);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  void _showPdfOptions(dynamic file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Preview'),
              onTap: () async {
                Navigator.pop(context);
                await _pdfService.previewPdf(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () async {
                Navigator.pop(context);
                await _pdfService.sharePdf(
                  file,
                  'Transaction Report',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print'),
              onTap: () async {
                Navigator.pop(context);
                await _pdfService.printPdf(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating PDF...'),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Date Range
            Text(
              'Custom Date Range',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Range',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormatter.format(_startDate)} - ${DateFormatter.format(_endDate)}',
                                style:
                                Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.edit_calendar),
                            label: const Text('Change Date'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _generateReport,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Generate'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Monthly Reports
            Text(
              'Monthly Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Last 6 months
            ...List.generate(6, (index) {
              final month = DateTime(
                DateTime.now().year,
                DateTime.now().month - index,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(DateFormatter.getMonthYear(month)),
                  subtitle: const Text('Generate monthly report'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _generateMonthlyReport(month),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}