import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/day_counter.dart';
import '../providers/day_counter_provider.dart';
import '../widgets/modern_form_field.dart';

class DayCounterFormScreen extends StatefulWidget {
  final DayCounter? dayCounter;

  const DayCounterFormScreen({super.key, this.dayCounter});

  @override
  State<DayCounterFormScreen> createState() => _DayCounterFormScreenState();
}

class _DayCounterFormScreenState extends State<DayCounterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _cashController = TextEditingController();
  final _upiController = TextEditingController();
  final _cardController = TextEditingController();
  final _creditController = TextEditingController();
  final _expensesController = TextEditingController();
  final _cashHandOverController = TextEditingController();
  final _closingBalanceController = TextEditingController();
  final _remarksController = TextEditingController();

  double _totalDayCounter = 0;
  double _actualClosingCounter = 0;
  double _difference = 0;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _cashController.addListener(_calculateFields);
    _upiController.addListener(_calculateFields);
    _cardController.addListener(_calculateFields);
    _creditController.addListener(_calculateFields);
    _openingBalanceController.addListener(_calculateFields);
    _expensesController.addListener(_calculateFields);
    _cashHandOverController.addListener(_calculateFields);
    _closingBalanceController.addListener(_calculateFields);

    if (widget.dayCounter != null) {
      _dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.dayCounter!.date);
      _openingBalanceController.text =
          widget.dayCounter!.openingBalance.toString();
      _cashController.text = widget.dayCounter!.payments.cash.toString();
      _upiController.text = widget.dayCounter!.payments.upi.toString();
      _cardController.text = widget.dayCounter!.payments.card.toString();
      _creditController.text = widget.dayCounter!.payments.credit.toString();
      _expensesController.text = widget.dayCounter!.expenses.toString();
      _cashHandOverController.text = widget.dayCounter!.cashHandOver.toString();
      _closingBalanceController.text =
          widget.dayCounter!.closingBalance.toString();
      _remarksController.text = widget.dayCounter!.remarks;
    }

    _calculateFields();
  }

  void _calculateFields() {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final upi = double.tryParse(_upiController.text) ?? 0;
    final card = double.tryParse(_cardController.text) ?? 0;
    final credit = double.tryParse(_creditController.text) ?? 0;
    final opening = double.tryParse(_openingBalanceController.text) ?? 0;
    final expenses = double.tryParse(_expensesController.text) ?? 0;
    final cashHandOver = double.tryParse(_cashHandOverController.text) ?? 0;
    final closing = double.tryParse(_closingBalanceController.text) ?? 0;

    setState(() {
      _totalDayCounter = cash + upi + card + credit;
      _actualClosingCounter = (opening + cash) - expenses;
      _difference = _actualClosingCounter - (closing + cashHandOver);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now() && mounted) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dayCounter = DayCounter(
          date: DateTime.parse(_dateController.text),
          openingBalance: double.parse(_openingBalanceController.text),
          payments: Payments(
            cash: double.parse(_cashController.text),
            upi: double.parse(_upiController.text),
            card: double.parse(_cardController.text),
            credit: double.parse(_creditController.text),
          ),
          expenses: double.parse(_expensesController.text),
          totalDayCounter: _totalDayCounter,
          cashHandOver: double.parse(_cashHandOverController.text),
          actualClosingCounter: _actualClosingCounter,
          closingBalance: double.parse(_closingBalanceController.text),
          difference: _difference,
          remarks: _remarksController.text,
        );

        if (widget.dayCounter != null) {
          final id = widget.dayCounter!.id ?? '';
          await Provider.of<DayCounterProvider>(
            context,
            listen: false,
          ).updateDayCounter(id, dayCounter);
        } else {
          await Provider.of<DayCounterProvider>(
            context,
            listen: false,
          ).addDayCounter(dayCounter);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving day counter: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _openingBalanceController.dispose();
    _cashController.dispose();
    _upiController.dispose();
    _cardController.dispose();
    _creditController.dispose();
    _expensesController.dispose();
    _cashHandOverController.dispose();
    _closingBalanceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dayCounter != null ? 'Edit Day Counter' : 'Add Day Counter',
        ),
        elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Field
              ModernFormField(
                label: 'Date',
                prefixIcon: Icons.calendar_today,
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _dateController.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Opening Balance Field
              ModernFormField(
                label: 'Opening Balance',
                prefixIcon: Icons.account_balance_wallet,
                child: TextFormField(
                  controller: _openingBalanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter opening balance';
                    }
                    return null;
                  },
                ),
              ),

              // Payments Section
              const Text(
                'Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Cash Field
              ModernFormField(
                label: 'Cash',
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter cash amount';
                    }
                    return null;
                  },
                ),
              ),

              // UPI Field
              ModernFormField(
                label: 'UPI',
                prefixIcon: Icons.phone_android,
                child: TextFormField(
                  controller: _upiController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter UPI amount';
                    }
                    return null;
                  },
                ),
              ),

              // Card Field
              ModernFormField(
                label: 'Card',
                prefixIcon: Icons.credit_card,
                child: TextFormField(
                  controller: _cardController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card amount';
                    }
                    return null;
                  },
                ),
              ),

              // Credit Field
              ModernFormField(
                label: 'Credit',
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter credit amount';
                    }
                    return null;
                  },
                ),
              ),

              // --- Auto-calculated: Total Day Counter ---
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.summarize, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Total Day Counter:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _totalDayCounter.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expenses Field
              ModernFormField(
                label: 'Expenses',
                prefixIcon: Icons.receipt_long,
                child: TextFormField(
                  controller: _expensesController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expenses amount';
                    }
                    return null;
                  },
                ),
              ),

              // Cash Hand Over Field
              ModernFormField(
                label: 'Cash Hand Over',
                prefixIcon: Icons.handshake,
                child: TextFormField(
                  controller: _cashHandOverController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cash hand over amount';
                    }
                    return null;
                  },
                ),
              ),

              // Closing Balance Field
              ModernFormField(
                label: 'Closing Balance',
                prefixIcon: Icons.account_balance,
                child: TextFormField(
                  controller: _closingBalanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter closing balance';
                    }
                    return null;
                  },
                ),
              ),

              // --- Auto-calculated: Actual Closing Counter ---
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Actual Closing Counter:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _actualClosingCounter.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Auto-calculated: Difference ---
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _difference.abs() < 0.01
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          _difference.abs() < 0.01 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Difference:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _difference.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _difference.abs() < 0.01
                                  ? Colors.green
                                  : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Remarks Field
              ModernFormField(
                label: 'Remarks',
                prefixIcon: Icons.note,
                child: TextFormField(
                  controller: _remarksController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  widget.dayCounter != null ? 'Update' : 'Save',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
