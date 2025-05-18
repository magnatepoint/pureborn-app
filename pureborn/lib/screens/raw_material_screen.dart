import 'package:flutter/material.dart';
import '../models/raw_material.dart';
import '../services/raw_material_service.dart';

class RawMaterialScreen extends StatefulWidget {
  const RawMaterialScreen({super.key});

  @override
  State<RawMaterialScreen> createState() => _RawMaterialScreenState();
}

class _RawMaterialScreenState extends State<RawMaterialScreen> {
  final RawMaterialService _service = RawMaterialService();
  List<RawMaterial> _materials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _loading = true);
    try {
      _materials = await _service.getAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showForm({RawMaterial? material}) {
    final nameController = TextEditingController(text: material?.name ?? '');
    final descController = TextEditingController(
      text: material?.description ?? '',
    );
    final categoryController = TextEditingController(
      text: material?.category ?? '',
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              material == null ? 'Add Raw Material' : 'Edit Raw Material',
            ),
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
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
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
                  final newMaterial = RawMaterial(
                    id: material?.id ?? '',
                    name: nameController.text,
                    description: descController.text,
                    category: categoryController.text,
                  );
                  try {
                    if (material == null) {
                      await _service.create(newMaterial);
                    } else {
                      await _service.update(material.id, newMaterial);
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _fetchMaterials();
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

  void _deleteMaterial(String id) async {
    try {
      await _service.delete(id);
      if (!mounted) return;
      _fetchMaterials();
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
      appBar: AppBar(title: Text('Raw Materials')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _materials.length,
                itemBuilder: (ctx, i) {
                  final m = _materials[i];
                  return ListTile(
                    title: Text(m.name),
                    subtitle: Text(m.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showForm(material: m),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteMaterial(m.id),
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
