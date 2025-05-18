import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../services/vendor_service.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final VendorService _service = VendorService();
  List<Vendor> _vendors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() => _loading = true);
    try {
      _vendors = await _service.getAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _showForm({Vendor? vendor}) {
    final nameController = TextEditingController(text: vendor?.name ?? '');
    final contactController = TextEditingController(
      text: vendor?.contact ?? '',
    );
    final addressController = TextEditingController(
      text: vendor?.address ?? '',
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(vendor == null ? 'Add Vendor' : 'Edit Vendor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
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
                  final newVendor = Vendor(
                    id: vendor?.id ?? '',
                    name: nameController.text,
                    contact: contactController.text,
                    address: addressController.text,
                  );
                  try {
                    if (vendor == null) {
                      await _service.create(newVendor);
                    } else {
                      await _service.update(vendor.id, newVendor);
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _fetchVendors();
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

  void _deleteVendor(String id) async {
    try {
      await _service.delete(id);
      if (!mounted) return;
      _fetchVendors();
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
      appBar: AppBar(title: Text('Vendors')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _vendors.length,
                itemBuilder: (ctx, i) {
                  final v = _vendors[i];
                  return ListTile(
                    title: Text(v.name),
                    subtitle: Text(v.contact ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showForm(vendor: v),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteVendor(v.id),
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
