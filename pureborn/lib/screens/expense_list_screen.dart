import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => ExpenseListScreenState();
}

class ExpenseListScreenState extends State<ExpenseListScreen> {
  final _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
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
      });
      final expenses = await _expenseService.getExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading expenses: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await _expenseService.deleteExpense(id);
      await _loadExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting expense: $e')));
      }
    }
  }

  Color _getStatusColor(double balanceDue) {
    if (balanceDue == 0) {
      return Colors.green;
    } else if (balanceDue < 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'utilities':
        return Icons.power;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _expenses.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.summarize, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Today\'s Summary',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(179),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(
                                    _expenses.fold<double>(
                                      0.0,
                                      (sum, expense) => sum + expense.total,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Balance Due',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(179),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(
                                    _expenses.fold<double>(
                                      0.0,
                                      (sum, expense) =>
                                          sum + expense.balanceDue,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expense List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ExpenseScreen(expense: expense),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadExpenses();
                                  }
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              SlidableAction(
                                onPressed: (_) => _deleteExpense(expense.id),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getStatusColor(expense.balanceDue),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(expense.category),
                                      color: Colors.white.withAlpha(179),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        expense.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ExpenseScreen(
                                                  expense: expense,
                                                ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadExpenses();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  expense.description,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.white.withAlpha(179),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(expense.date),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(179),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Payment summary
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (expense.payment.cash > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.money,
                                              size: 16,
                                              color: Colors.white.withAlpha(
                                                179,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Cash: ${_currencyFormat.format(expense.payment.cash)}',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(
                                                  179,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      if (expense.payment.online > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_android,
                                              size: 16,
                                              color: Colors.white.withAlpha(
                                                179,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Online: ${_currencyFormat.format(expense.payment.online)}',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(
                                                  179,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      if (expense.payment.credit > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance,
                                              size: 16,
                                              color: Colors.white.withAlpha(
                                                179,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Credit: ${_currencyFormat.format(expense.payment.credit)}',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(
                                                  179,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Category: ',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      expense.category,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total: ${_currencyFormat.format(expense.total)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Balance: ${_currencyFormat.format(expense.balanceDue)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpenseScreen()),
          );
          if (result == true) {
            _loadExpenses();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
