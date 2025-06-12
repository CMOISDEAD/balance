import 'package:flutter/material.dart';
import 'package:new_app/database/database.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:relative_time/relative_time.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final FinanceProvider provider;


  const TransactionTile({super.key,
    required this.transaction,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
      '${RelativeTime(context).format(transaction.createdAt)} ${transaction.category != null ? ' • ${transaction.category}' : ''}',
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isIncome ? '+' : '-'}$amount',
          style: TextStyle(
            color: isIncome
                ? Colors.green
                : Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
    onLongPress: () => _showDeleteDialog(context, transaction, provider),
  );
  }
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
