import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'package:intl/intl.dart';
import '../widgets/modern_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final expenses = await _expenseService.getExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  double _calculateTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.total);
  }

  double _calculateTotalBalanceDue() {
    return _expenses.fold(0, (sum, expense) => sum + expense.balanceDue);
  }

  Map<String, double> _calculateExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.total;
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading expenses:',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadExpenses,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadExpenses,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final totalExpenses = _calculateTotalExpenses();
    final totalBalanceDue = _calculateTotalBalanceDue();
    final categoryTotals = _calculateExpensesByCategory();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _loadExpenses,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          ModernCard(
            title: 'Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Total Expenses', totalExpenses),
                _buildSummaryRow('Total Balance Due', totalBalanceDue),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ModernCard(
            title: 'Expenses by Category',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...categoryTotals.entries.map(
                  (entry) => _buildSummaryRow(entry.key, entry.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            _currencyFormat.format(value),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
