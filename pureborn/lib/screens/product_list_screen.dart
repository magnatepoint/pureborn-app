import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_form_screen.dart';
import '../widgets/modern_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null) {
            return Center(child: Text('Error: ${productProvider.error}'));
          }

          if (productProvider.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.builder(
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return ProductListTile(product: product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;

  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: product.name,
      subtitle: 'Category: ${product.category}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('₹${product.sellingPrice}'),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Product'),
                      content: const Text(
                        'Are you sure you want to delete this product?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<ProductProvider>().deleteProduct(
                              product.id!,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      accentColor: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code: ${product.productCode}'),
          Text('Quantity: ${product.quantity}'),
        ],
      ),
    );
  }
}
