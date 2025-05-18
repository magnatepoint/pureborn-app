import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/day_counter_provider.dart';
import 'day_counter_form_screen.dart';

class DayCounterScreen extends StatefulWidget {
  const DayCounterScreen({super.key});

  @override
  State<DayCounterScreen> createState() => _DayCounterScreenState();
}

class _DayCounterScreenState extends State<DayCounterScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    Provider.of<DayCounterProvider>(context, listen: false).loadDayCounters();
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
        title: const Text('Day Counter'),
        elevation: 1,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<DayCounterProvider>(
        builder: (context, dayCounterProvider, child) {
          if (dayCounterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dayCounterProvider.error != null) {
            return Center(child: Text('Error: ${dayCounterProvider.error}'));
          }
          if (dayCounterProvider.dayCounters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No day counters found',
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
                              'Total Entries',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dayCounterProvider.dayCounters.length.toString(),
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
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.white.withAlpha(179),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencyFormat.format(
                                dayCounterProvider.dayCounters.fold<double>(
                                  0.0,
                                  (sum, counter) => sum + counter.amount,
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
              // Day Counter List
              Expanded(
                child: ListView.builder(
                  itemCount: dayCounterProvider.dayCounters.length,
                  itemBuilder: (context, index) {
                    final counter = dayCounterProvider.dayCounters[index];
                    final counterId = counter.id;
                    if (counterId == null) {
                      // fallback to non-dismissible if no id
                      return _buildDayCounterCard(counter, dayCounterProvider);
                    }
                    return Dismissible(
                      key: Key(counterId),
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
                                title: const Text('Delete Day Counter'),
                                content: const Text(
                                  'Are you sure you want to delete this entry?',
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
                        final messenger = ScaffoldMessenger.of(context);
                        await dayCounterProvider.deleteDayCounter(counterId);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Day counter deleted')),
                        );
                      },
                      child: _buildDayCounterCard(counter, dayCounterProvider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final provider = Provider.of<DayCounterProvider>(
            context,
            listen: false,
          );
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DayCounterFormScreen(),
            ),
          );
          if (result != null) {
            provider.loadDayCounters();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildDayCounterCard(counter, DayCounterProvider dayCounterProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(counter.balanceDue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withAlpha(179)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  counter.description,
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              DayCounterFormScreen(dayCounter: counter),
                    ),
                  );
                  if (result != null) {
                    if (!mounted) return;
                    dayCounterProvider.loadDayCounters();
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
                DateFormat('MMM dd, yyyy').format(counter.date),
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: Colors.white.withAlpha(179),
                ),
                const SizedBox(width: 4),
                Text(
                  'Payment: ${counter.paymentMethod}',
                  style: TextStyle(color: Colors.white.withAlpha(179)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: ${_currencyFormat.format(counter.amount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Balance: ${_currencyFormat.format(counter.balanceDue)}',
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
