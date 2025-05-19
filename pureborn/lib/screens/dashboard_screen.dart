import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'package:intl/intl.dart';
import '../widgets/modern_card.dart';
import '../models/purchase.dart';
import '../services/purchase_service.dart';
import '../models/day_counter.dart';
import '../services/day_counter_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../models/vendor.dart';
import '../services/vendor_service.dart';
import '../models/raw_material.dart';
import '../services/raw_material_service.dart';
import '../models/purchase_category.dart';
import '../services/purchase_category_service.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _expenseService = ExpenseService();
  final _purchaseService = PurchaseService(baseUrl: Constants.apiUrl);
  final _dayCounterService = DayCounterService();
  final _productService = ProductService();
  final _vendorService = VendorService();
  final _rawMaterialService = RawMaterialService();
  final _purchaseCategoryService = PurchaseCategoryService();

  List<Expense> _expenses = [];
  List<Purchase> _purchases = [];
  List<DayCounter> _dayCounters = [];
  List<Product> _products = [];
  List<Vendor> _vendors = [];
  List<RawMaterial> _rawMaterials = [];
  List<PurchaseCategory> _purchaseCategories = [];

  bool _isLoading = true;
  String? _error;
  String? _purchaseError;
  String? _dayCounterError;
  String? _productError;
  String? _vendorError;
  String? _rawMaterialError;
  String? _purchaseCategoryError;
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadPurchases();
    _loadDayCounters();
    _loadProducts();
    _loadVendors();
    _loadRawMaterials();
    _loadPurchaseCategories();
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

  Future<void> _loadPurchases() async {
    try {
      final purchases = await _purchaseService.getPurchases();
      setState(() {
        _purchases = purchases;
        _purchaseError = null;
      });
    } catch (e) {
      setState(() {
        _purchaseError = e.toString();
      });
    }
  }

  Future<void> _loadDayCounters() async {
    try {
      final dayCounters = await _dayCounterService.getDayCounters();
      setState(() {
        _dayCounters = dayCounters;
        _dayCounterError = null;
      });
    } catch (e) {
      setState(() {
        _dayCounterError = e.toString();
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _productError = null;
      });
    } catch (e) {
      setState(() {
        _productError = e.toString();
      });
    }
  }

  Future<void> _loadVendors() async {
    try {
      final vendors = await _vendorService.getAll();
      setState(() {
        _vendors = vendors;
        _vendorError = null;
      });
    } catch (e) {
      setState(() {
        _vendorError = e.toString();
      });
    }
  }

  Future<void> _loadRawMaterials() async {
    try {
      final rawMaterials = await _rawMaterialService.getAll();
      setState(() {
        _rawMaterials = rawMaterials;
        _rawMaterialError = null;
      });
    } catch (e) {
      setState(() {
        _rawMaterialError = e.toString();
      });
    }
  }

  Future<void> _loadPurchaseCategories() async {
    try {
      final purchaseCategories = await _purchaseCategoryService.getAll();
      setState(() {
        _purchaseCategories = purchaseCategories;
        _purchaseCategoryError = null;
      });
    } catch (e) {
      setState(() {
        _purchaseCategoryError = e.toString();
      });
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
                onPressed: () {
                  _loadExpenses();
                  _loadPurchases();
                  _loadDayCounters();
                  _loadProducts();
                  _loadVendors();
                  _loadRawMaterials();
                  _loadPurchaseCategories();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh All'),
              ),
            ],
          ),
          ModernCard(
            title: 'Purchases Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.blue,
            child:
                _purchaseError != null
                    ? Text('Error: [31m$_purchaseError[0m')
                    : _purchases.isEmpty
                    ? const Text('No purchases found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Purchases',
                          _purchases.length.toDouble(),
                        ),
                        _buildSummaryRow(
                          'Total Purchase Value',
                          _purchases.fold(0, (sum, p) => sum + p.total),
                        ),
                      ],
                    ),
          ),
          ModernCard(
            title: 'Day Counters Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.purple,
            child:
                _dayCounterError != null
                    ? Text('Error: [31m$_dayCounterError[0m')
                    : _dayCounters.isEmpty
                    ? const Text('No day counters found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Day Counters',
                          _dayCounters.length.toDouble(),
                        ),
                        _buildSummaryRow(
                          'Total Amount',
                          _dayCounters.fold(
                            0,
                            (sum, d) => sum + d.totalDayCounter,
                          ),
                        ),
                      ],
                    ),
          ),
          ModernCard(
            title: 'Products Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.teal,
            child:
                _productError != null
                    ? Text('Error: [31m$_productError[0m')
                    : _products.isEmpty
                    ? const Text('No products found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Products',
                          _products.length.toDouble(),
                        ),
                        _buildSummaryRow(
                          'Total Stock',
                          _products.fold(0, (sum, p) => sum + p.quantity),
                        ),
                      ],
                    ),
          ),
          ModernCard(
            title: 'Vendors Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.indigo,
            child:
                _vendorError != null
                    ? Text('Error: [31m$_vendorError[0m')
                    : _vendors.isEmpty
                    ? const Text('No vendors found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Vendors',
                          _vendors.length.toDouble(),
                        ),
                      ],
                    ),
          ),
          ModernCard(
            title: 'Raw Materials Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.brown,
            child:
                _rawMaterialError != null
                    ? Text('Error: [31m$_rawMaterialError[0m')
                    : _rawMaterials.isEmpty
                    ? const Text('No raw materials found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Raw Materials',
                          _rawMaterials.length.toDouble(),
                        ),
                      ],
                    ),
          ),
          ModernCard(
            title: 'Purchase Categories Summary',
            padding: const EdgeInsets.all(16.0),
            accentColor: Colors.deepOrange,
            child:
                _purchaseCategoryError != null
                    ? Text('Error: [31m$_purchaseCategoryError[0m')
                    : _purchaseCategories.isEmpty
                    ? const Text('No purchase categories found')
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(
                          'Total Purchase Categories',
                          _purchaseCategories.length.toDouble(),
                        ),
                      ],
                    ),
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
