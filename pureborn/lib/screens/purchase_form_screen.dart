import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase.dart';
import '../services/purchase_category_service.dart';
import '../services/raw_material_service.dart';
import '../services/vendor_service.dart';
import '../config/app_config.dart';
import '../services/purchase_service.dart';
import '../models/raw_material.dart';
import '../utils/logger.dart';

class PurchaseFormScreen extends StatefulWidget {
  final Purchase? purchase;

  const PurchaseFormScreen({super.key, this.purchase});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late String _purchaseCategory;
  late String _selectedRawMaterial;
  late double _pricePerKg;
  late double _quantity;
  late String _vendor;
  late double _total;
  late double _balanceDue;
  final List<Map<String, dynamic>> _payments = [
    {'method': 'Cash', 'amount': 0.0},
    {'method': 'Upi', 'amount': 0.0},
    {'method': 'Card', 'amount': 0.0},
    {'method': 'Credit', 'amount': 0.0},
  ];

  final List<String> _rawMaterials = [
    'Material 1',
    'Material 2',
    'Material 3',
  ]; // Replace with actual data
  final List<String> _categories = [
    'Category 1',
    'Category 2',
    'Category 3',
  ]; // Replace with actual data
  final List<String> _vendors = [
    'Vendor 1',
    'Vendor 2',
    'Vendor 3',
  ]; // Replace with actual data

  // Add controllers for price, quantity, and payment fields
  TextEditingController _pricePerKgController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _totalController = TextEditingController();
  TextEditingController _balanceDueController = TextEditingController();
  final List<TextEditingController> _paymentControllers = [
    TextEditingController(text: '0.0'),
    TextEditingController(text: '0.0'),
    TextEditingController(text: '0.0'),
    TextEditingController(text: '0.0'),
  ];

  bool _loadingDropdowns = true;
  bool _saving = false;

  List<RawMaterial> _rawMaterialObjects = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
    _selectedDate = widget.purchase?.date ?? DateTime.now();
    _purchaseCategory = widget.purchase?.purchaseCategory ?? _categories.first;
    _selectedRawMaterial = widget.purchase?.rawMaterial ?? _rawMaterials.first;
    _pricePerKg = widget.purchase?.pricePerKg ?? 0.0;
    _quantity = widget.purchase?.quantity ?? 0.0;
    _total = _pricePerKg * _quantity;
    _balanceDue = _total;
    if (widget.purchase?.vendor != null &&
        _vendors.contains(widget.purchase!.vendor)) {
      _vendor = widget.purchase!.vendor;
    } else {
      _vendor = _vendors.first;
    }
    // Always show all four payment methods
    if (widget.purchase != null) {
      for (int i = 0; i < _payments.length; i++) {
        if (_payments[i]['method'] == widget.purchase!.paymentMethod) {
          _payments[i]['amount'] = widget.purchase!.payment;
          _paymentControllers[i].text = widget.purchase!.payment.toString();
        } else {
          _payments[i]['amount'] = 0.0;
          _paymentControllers[i].text = '0.0';
        }
      }
    }
    _pricePerKgController = TextEditingController(text: _pricePerKg.toString());
    _quantityController = TextEditingController(text: _quantity.toString());
    _totalController = TextEditingController(text: _total.toStringAsFixed(2));
    _balanceDueController = TextEditingController(
      text: _balanceDue.toStringAsFixed(2),
    );
    _pricePerKgController.addListener(_calculateTotals);
    _quantityController.addListener(_calculateTotals);
    for (final c in _paymentControllers) {
      c.addListener(_calculateTotals);
    }
    _calculateTotals();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => _loadingDropdowns = true);
    try {
      final categories = await PurchaseCategoryService().getAll();
      final materials = await RawMaterialService().getAll();
      final vendors = await VendorService().getAll();
      setState(() {
        _categories.clear();
        _categories.addAll(categories.map((c) => c.name));
        _rawMaterials.clear();
        _rawMaterials.addAll(materials.map((m) => m.name));
        _vendors.clear();
        _vendors.addAll(vendors.map((v) => v.name));
        _rawMaterialObjects = materials;
        // Set defaults if needed
        if (!_categories.contains(_purchaseCategory) &&
            _categories.isNotEmpty) {
          _purchaseCategory = _categories.first;
        }
        if (!_rawMaterials.contains(_selectedRawMaterial) &&
            _rawMaterials.isNotEmpty) {
          _selectedRawMaterial = _rawMaterials.first;
        }
        if (!_vendors.contains(_vendor) && _vendors.isNotEmpty) {
          _vendor = _vendors.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dropdowns: $e')));
      }
    }
    setState(() => _loadingDropdowns = false);
  }

  @override
  void dispose() {
    _pricePerKgController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    _balanceDueController.dispose();
    for (final c in _paymentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculateTotals() {
    setState(() {
      _pricePerKg = double.tryParse(_pricePerKgController.text) ?? 0.0;
      _quantity = double.tryParse(_quantityController.text) ?? 0.0;
      _total = _pricePerKg * _quantity;
      _totalController.text = _total.toStringAsFixed(2);
      for (int i = 0; i < _payments.length; i++) {
        _payments[i]['amount'] =
            double.tryParse(_paymentControllers[i].text) ?? 0.0;
      }
      final totalPayment = _payments.fold<double>(
        0.0,
        (sum, p) => sum + (p['amount'] ?? 0.0),
      );
      _balanceDue = _total - totalPayment;
      _balanceDueController.text = _balanceDue.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchase == null ? 'New Purchase' : 'Edit Purchase'),
      ),
      body:
          _loadingDropdowns
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date Picker
                      ListTile(
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Purchase Category Dropdown
                      DropdownButtonFormField<String>(
                        value:
                            _categories.contains(_purchaseCategory)
                                ? _purchaseCategory
                                : _categories.first,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Category',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _purchaseCategory = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Raw Material Dropdown
                      DropdownButtonFormField<String>(
                        value:
                            _rawMaterials.contains(_selectedRawMaterial)
                                ? _selectedRawMaterial
                                : _rawMaterials.first,
                        decoration: const InputDecoration(
                          labelText: 'Raw Material',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _rawMaterials.map((String material) {
                              return DropdownMenuItem<String>(
                                value: material,
                                child: Text(material),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRawMaterial = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Price per kg
                      TextFormField(
                        controller: _pricePerKgController,
                        decoration: const InputDecoration(
                          labelText: 'Price per kg',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Total (read-only)
                      TextFormField(
                        controller: _totalController,
                        decoration: const InputDecoration(
                          labelText: 'Total',
                          border: OutlineInputBorder(),
                          helperText: 'Total = Price/kg × Quantity',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Vendor Dropdown
                      DropdownButtonFormField<String>(
                        value:
                            _vendors.contains(_vendor)
                                ? _vendor
                                : _vendors.first,
                        decoration: const InputDecoration(
                          labelText: 'Vendor',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _vendors.map((String vendor) {
                              return DropdownMenuItem<String>(
                                value: vendor,
                                child: Text(vendor),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _vendor = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Methods (always four fields)
                      (_payments.isEmpty || _paymentControllers.isEmpty)
                          ? const Text('No payment methods available.')
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (
                                int i = 0;
                                i < _payments.length &&
                                    i < _paymentControllers.length;
                                i++
                              )
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _payments[i]['method'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _paymentControllers[i],
                                        decoration: InputDecoration(
                                          labelText: 'Amount',
                                          border: const OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      const SizedBox(height: 16),

                      // Balance Due (read-only)
                      TextFormField(
                        controller: _balanceDueController,
                        decoration: const InputDecoration(
                          labelText: 'Balance Due',
                          border: OutlineInputBorder(),
                          helperText: 'Balance Due = Total - Payment',
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed:
                            _saving
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _saving = true);
                                    final totalPayment = _payments.fold<double>(
                                      0.0,
                                      (sum, p) => sum + (p['amount'] ?? 0.0),
                                    );
                                    String paymentMethod =
                                        _payments.firstWhere(
                                          (p) => (p['amount'] ?? 0.0) > 0,
                                          orElse: () => _payments[0],
                                        )['method'];
                                    AppLogger.info(
                                      'Available raw materials: ${_rawMaterialObjects.map((m) => '${m.name} (${m.id})').join(', ')}',
                                    );
                                    AppLogger.info(
                                      'Selected raw material: $_selectedRawMaterial',
                                    );
                                    RawMaterial? rawMaterialObj;
                                    try {
                                      rawMaterialObj = _rawMaterialObjects
                                          .firstWhere(
                                            (m) =>
                                                m.name == _selectedRawMaterial,
                                          );
                                    } catch (_) {
                                      rawMaterialObj = null;
                                    }
                                    final rawMaterialId =
                                        rawMaterialObj?.id ?? '';
                                    AppLogger.info(
                                      'Mapped raw material id: $rawMaterialId',
                                    );
                                    if (rawMaterialId.isEmpty) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Invalid raw material selection. Please try again.',
                                          ),
                                        ),
                                      );
                                      setState(() => _saving = false);
                                      return;
                                    }
                                    final purchase = Purchase(
                                      date: _selectedDate,
                                      purchaseCategory: _purchaseCategory,
                                      rawMaterial: rawMaterialId,
                                      pricePerKg: _pricePerKg,
                                      quantity: _quantity,
                                      total: _total,
                                      vendor: _vendor,
                                      payment: totalPayment,
                                      paymentMethod: paymentMethod,
                                      balanceDue: _balanceDue,
                                    );
                                    PurchaseService(
                                          baseUrl: AppConfig.apiBaseUrl
                                              .replaceFirst('/api', ''),
                                        )
                                        .createPurchase(purchase)
                                        .then(
                                          (_) =>
                                              _handlePurchaseSuccess(purchase),
                                        )
                                        .catchError(
                                          (e) => _handlePurchaseError(e),
                                        )
                                        .whenComplete(() {
                                          if (mounted) {
                                            setState(() => _saving = false);
                                          }
                                        });
                                  }
                                },
                        child:
                            _saving
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save Purchase'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  void _handlePurchaseSuccess(Purchase purchase) {
    if (!mounted) return;
    Navigator.pop(context, purchase);
  }

  void _handlePurchaseError(dynamic error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to save purchase: $error')));
  }
}
