import 'package:flutter/material.dart';
import 'package:balance/components/ui/transactions/transaction_tile.dart';
import 'package:balance/database/database.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:intl/intl.dart';

class GroupedTransactionsList extends StatelessWidget {
  final FinanceProvider provider;

  const GroupedTransactionsList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Transaction>>>(
      future: provider.database.getTransactionsGroupedByDate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final groupedTransactions = snapshot.data ?? {};

        if (groupedTransactions.isEmpty) {
          return const Center(child: Text('No transactions found'));
        }

        // Sort dates in descending order
        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final transactions = groupedTransactions[date]!;
            final dateLabel = _getDateLabel(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la fecha
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${transactions.length} transaction${transactions.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de transacciones para esa fecha
                ...transactions.map(
                  (transaction) => TransactionTile(
                    transaction: transaction,
                    provider: provider,
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            );
          },
        );
      },
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return "Today";
    } else if (date == yesterday) {
      return "Yesterday";
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      // For dates from last week, show the day of the week.
      return DateFormat('EEEE').format(date);
    } else if (date.year == now.year) {
      // For date from the current year, show the day of week.
      return DateFormat('d \'de\' MMMM').format(date);
    } else {
      // For dates of previous years, show full date.
      return DateFormat('d \'de\' MMMM \'de\' yyyy').format(date);
    }
  }
}
