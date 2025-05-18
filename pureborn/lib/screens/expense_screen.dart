import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/modern_dialog.dart';

class ExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final void Function()? onSaved;

  const ExpenseScreen({super.key, this.expense, this.onSaved});

  static Future<void> show(
    BuildContext context, {
    Expense? expense,
    void Function()? onSaved,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: ExpenseScreen(expense: expense, onSaved: onSaved),
          ),
    );
  }

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cashController = TextEditingController();
  final _onlineController = TextEditingController();
  final _creditController = TextEditingController();
  final _totalController = TextEditingController();
  final _balanceDueController = TextEditingController();
  final _expenseService = ExpenseService();
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Medical',
    'Education',
    'Travel',
    'Bills',
    'Grocery',
    'Rent',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text = widget.expense!.name;
      _descriptionController.text = widget.expense!.description;
      _categoryController.text = widget.expense!.category;
      _cashController.text = widget.expense!.payment.cash.toString();
      _onlineController.text = widget.expense!.payment.online.toString();
      _creditController.text = widget.expense!.payment.credit.toString();
      _totalController.text = widget.expense!.total.toString();
      _balanceDueController.text = widget.expense!.balanceDue.toString();
      _date = widget.expense!.date;
    }
    _cashController.addListener(_updateTotal);
    _onlineController.addListener(_updateTotal);
    _creditController.addListener(_updateTotal);
  }

  void _updateTotal() {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final online = double.tryParse(_onlineController.text) ?? 0;
    final credit = double.tryParse(_creditController.text) ?? 0;
    final total = cash + online + credit;
    _totalController.text = total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _cashController.dispose();
    _onlineController.dispose();
    _creditController.dispose();
    _totalController.dispose();
    _balanceDueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    // Ensure category is always valid before saving
    if (_categoryController.text.isEmpty ||
        !_categories.contains(_categoryController.text)) {
      _categoryController.text = _categories.first;
    }
    if (_formKey.currentState!.validate()) {
      try {
        final expense = Expense(
          id: widget.expense?.id ?? '',
          date: _date,
          name: _nameController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          payment: Payment(
            cash: double.tryParse(_cashController.text) ?? 0,
            online: double.tryParse(_onlineController.text) ?? 0,
            credit: double.tryParse(_creditController.text) ?? 0,
          ),
          total: double.tryParse(_totalController.text) ?? 0,
          balanceDue: double.tryParse(_balanceDueController.text) ?? 0,
        );
        if (widget.expense == null) {
          await _expenseService.createExpense(expense);
        } else {
          await _expenseService.updateExpense(expense.id, expense);
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernDialog(
      title: widget.expense == null ? 'Add Expense' : 'Edit Expense',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernFormField(
                label: 'Date',
                prefixIcon: Icons.calendar_today,
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_date),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              ModernFormField(
                label: 'Name',
                prefixIcon: Icons.label,
                child: TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Description',
                prefixIcon: Icons.description,
                child: TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Category',
                prefixIcon: Icons.category,
                child: DropdownButtonFormField<String>(
                  value:
                      _categories.contains(_categoryController.text) &&
                              _categoryController.text.isNotEmpty
                          ? _categoryController.text
                          : _categories.first,
                  dropdownColor: Theme.of(context).cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  items:
                      _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _categoryController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Cash Amount',
                prefixIcon: Icons.money,
                child: TextFormField(
                  controller: _cashController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (_onlineController.text.isEmpty &&
                            _creditController.text.isEmpty)) {
                      return 'Enter at least one payment amount';
                    }
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Online Amount',
                prefixIcon: Icons.phone_android,
                child: TextFormField(
                  controller: _onlineController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (_cashController.text.isEmpty &&
                            _creditController.text.isEmpty)) {
                      return 'Enter at least one payment amount';
                    }
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Credit Amount',
                prefixIcon: Icons.account_balance,
                child: TextFormField(
                  controller: _creditController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (_cashController.text.isEmpty &&
                            _onlineController.text.isEmpty)) {
                      return 'Enter at least one payment amount';
                    }
                    if (value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Total',
                prefixIcon: Icons.calculate,
                child: TextFormField(
                  controller: _totalController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Total is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number for total';
                    }
                    return null;
                  },
                ),
              ),
              ModernFormField(
                label: 'Balance Due',
                prefixIcon: Icons.account_balance_wallet,
                child: TextFormField(
                  controller: _balanceDueController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Balance due is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number for balance due';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.expense != null)
          ModernButton(
            text: 'Delete',
            onPressed: () async {
              Future<void> handleDeleteSuccess() async {
                Navigator.of(context).pop(true);
                if (widget.onSaved != null) widget.onSaved!();
              }

              Future<void> handleDeleteError(String error) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting expense: $error')),
                );
              }

              try {
                await _expenseService.deleteExpense(widget.expense!.id);
                if (!mounted) return;
                await handleDeleteSuccess();
              } catch (e) {
                if (!mounted) return;
                await handleDeleteError(e.toString());
              }
            },
            isPrimary: false,
            icon: Icons.delete,
          ),
        ModernButton(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
          isPrimary: false,
          icon: Icons.close,
        ),
        ModernButton(
          text: widget.expense == null ? 'Add Expense' : 'Update Expense',
          onPressed: () async {
            await _saveExpense();
            if (widget.onSaved != null) widget.onSaved!();
          },
          icon: widget.expense == null ? Icons.add : Icons.save,
        ),
      ],
    );
  }
}
