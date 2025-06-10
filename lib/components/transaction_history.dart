import 'package:flutter/material.dart';
import 'package:new_app/database/database.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        final recentTransactions = provider.transactions.take(15).toList();

        return Expanded(
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('View All'),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No transactions found",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: recentTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = recentTransactions[index];
                            return _buildTransactionTile(
                              context,
                              transaction,
                              provider,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

Widget _buildTransactionTile(
  BuildContext context,
  Transaction transaction,
  FinanceProvider provider,
) {
  final isIncome = transaction.type == 'income';
  final amount = CurrencyHelper.formatCurrency(transaction.amount);

  return ListTile(
    leading: CircleAvatar(
      backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
      child: Icon(
        isIncome ? Icons.add : Icons.remove,
        color: isIncome ? Colors.green : Colors.red,
      ),
    ),
    title: Text(transaction.description),
    subtitle: Text(
      '${_formatDate(transaction.createdAt)}${transaction.category != null ? ' • ${transaction.category}' : ''}',
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isIncome ? '+' : '-'}$amount',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
    onLongPress: () => _showDeleteDialog(context, transaction, provider),
  );
}

void _showDeleteDialog(
  BuildContext context,
  Transaction transaction,
  FinanceProvider provider,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Transaction'),
      content: Text('Are you sure you want to delete this transaction?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await provider.deleteTransaction(transaction.id);
              Navigator.pop(context);
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting transaction'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
