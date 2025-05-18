import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _productCodeController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _hsnCodeController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
    _productCodeController = TextEditingController(
      text: widget.product?.productCode ?? '',
    );
    _costPriceController = TextEditingController(
      text: widget.product?.costPrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '',
    );
    _hsnCodeController = TextEditingController(
      text: widget.product?.hsnCode ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _productCodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _hsnCodeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text,
      category: _categoryController.text,
      productCode: _productCodeController.text,
      costPrice: double.parse(_costPriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      hsnCode: _hsnCodeController.text,
      quantity: int.parse(_quantityController.text),
    );

    if (widget.product == null) {
      context.read<ProductProvider>().addProduct(product);
    } else {
      context.read<ProductProvider>().updateProduct(
        widget.product!.id!,
        product,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productCodeController,
                decoration: InputDecoration(
                  labelText: 'Product Code',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cost price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a selling price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hsnCodeController,
                decoration: InputDecoration(
                  labelText: 'HSN Code',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an HSN code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(
                  widget.product == null ? 'Add Product' : 'Update Product',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
