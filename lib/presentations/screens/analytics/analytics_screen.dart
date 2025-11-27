import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../../../data/datasources/remote/firestore_service.dart';
import '../../widget/charts/monthely_chart.dart';
import '../../widget/charts/spending_chart.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = true;

  Map<String, double> _categoryData = {};
  Map<int, double> _monthlyIncome = {};
  Map<int, double> _monthlyExpense = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoryData = await _firestoreService.getCategoryWiseSpending();
      final monthlyData = await _firestoreService.getLast6MonthsData();

      setState(() {
        _categoryData = categoryData;
        _monthlyIncome = monthlyData['income'] ?? {};
        _monthlyExpense = monthlyData['expense'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Monthly Chart
              MonthlyChart(
                monthlyIncome: _monthlyIncome,
                monthlyExpense: _monthlyExpense,
              ),

              const SizedBox(height: 16),

              // Spending Chart
              SpendingChart(
                categoryData: _categoryData,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}