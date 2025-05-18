import 'package:flutter/material.dart';
import '../models/purchase_category.dart';
import '../services/purchase_category_service.dart';

class PurchaseCategoryScreen extends StatefulWidget {
  const PurchaseCategoryScreen({super.key});

  @override
  State<PurchaseCategoryScreen> createState() => _PurchaseCategoryScreenState();
}

class _PurchaseCategoryScreenState extends State<PurchaseCategoryScreen> {
  final PurchaseCategoryService _service = PurchaseCategoryService();
  List<PurchaseCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    try {
      _categories = await _service.getAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showForm({PurchaseCategory? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(category == null ? 'Add Category' : 'Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newCategory = PurchaseCategory(
                    id: category?.id ?? '',
                    name: nameController.text,
                    description: descController.text,
                  );
                  try {
                    if (category == null) {
                      await _service.create(newCategory);
                    } else {
                      await _service.update(category.id, newCategory);
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _fetchCategories();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteCategory(String id) async {
    try {
      await _service.delete(id);
      if (!mounted) return;
      _fetchCategories();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Purchase Categories')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final c = _categories[i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showForm(category: c),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCategory(c.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
