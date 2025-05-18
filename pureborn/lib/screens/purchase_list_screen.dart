import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_provider.dart';
import 'purchase_form_screen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    // Fetch purchases when the screen is first built
    Provider.of<PurchaseProvider>(context, listen: false).loadPurchases();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PurchaseProvider>(
        builder: (context, purchaseProvider, child) {
          if (purchaseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (purchaseProvider.error != null) {
            return Center(child: Text('Error: ${purchaseProvider.error}'));
          }
          if (purchaseProvider.purchases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No purchases found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return Column(
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
                              'Total Purchases',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(
                                purchaseProvider.purchases.fold<double>(
                                  0.0,
                                  (sum, purchase) => sum + purchase.total,
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
                                purchaseProvider.purchases.fold<double>(
                                  0.0,
                                  (sum, purchase) => sum + purchase.balanceDue,
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
              // Purchase List
              Expanded(
                child: ListView.builder(
                  itemCount: purchaseProvider.purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = purchaseProvider.purchases[index];
                    final purchaseId = purchase.id;
                    if (purchaseId == null) {
                      // fallback to non-dismissible if no id
                      return _buildPurchaseCard(purchase);
                    }
                    return Dismissible(
                      key: Key(purchaseId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Purchase'),
                                content: const Text(
                                  'Are you sure you want to delete this purchase?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      onDismissed: (direction) async {
                        final purchaseProvider = Provider.of<PurchaseProvider>(
                          context,
                          listen: false,
                        );
                        final messenger = ScaffoldMessenger.of(context);
                        await purchaseProvider.deletePurchase(purchaseId);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Purchase deleted')),
                        );
                      },
                      child: _buildPurchaseCard(purchase),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleAddPurchase(),
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase'),
      ),
    );
  }

  Future<void> _handleAddPurchase() async {
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PurchaseFormScreen()),
    );
    if (result != null && mounted) {
      Provider.of<PurchaseProvider>(context, listen: false).loadPurchases();
    }
  }

  Widget _buildPurchaseCard(purchase) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(purchase.balanceDue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.white.withAlpha(179)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  purchase.rawMaterial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () async {
                  final purchaseProvider = Provider.of<PurchaseProvider>(
                    context,
                    listen: false,
                  );
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PurchaseFormScreen(purchase: purchase),
                    ),
                  );
                  if (!mounted) return;
                  if (result != null) {
                    purchaseProvider.loadPurchases();
                  }
                },
              ),
            ],
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
                DateFormat('MMM dd, yyyy').format(purchase.date),
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.white.withAlpha(179)),
                const SizedBox(width: 4),
                Text(
                  'Vendor: ${purchase.vendor}',
                  style: TextStyle(color: Colors.white.withAlpha(179)),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.category,
                  size: 16,
                  color: Colors.white.withAlpha(179),
                ),
                const SizedBox(width: 4),
                Text(
                  'Category: ${purchase.purchaseCategory}',
                  style: TextStyle(color: Colors.white.withAlpha(179)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Colors.white.withAlpha(179)),
              const SizedBox(width: 4),
              Text(
                'Payment: ${purchase.paymentMethod}',
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_currencyFormat.format(purchase.total)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Balance: ${_currencyFormat.format(purchase.balanceDue)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
