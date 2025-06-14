import 'package:flutter/material.dart';
import 'package:balance/database/database.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:balance/utils/currency_helper.dart';
import 'package:relative_time/relative_time.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final FinanceProvider provider;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isTransfer =
        transaction.type == 'transfer_to' ||
        transaction.type == 'transfer_from';
    final isIncome = transaction.type == 'income';
    final amount = CurrencyHelper.formatCurrency(transaction.amount);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isTransfer
            ? Theme.of(context).colorScheme.primaryContainer
            : isIncome
            ? Colors.green.shade100
            : Colors.red.shade100,
        child: Icon(
          isTransfer
              ? Icons.credit_card
              : isIncome
              ? Icons.add
              : Icons.remove,
          color: isTransfer
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : isIncome
              ? Colors.green
              : Colors.red,
        ),
      ),
      title: Text(
        transaction.description,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${RelativeTime(context).format(transaction.createdAt)} ${transaction.category != null ? ' • ${transaction.category}' : ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${!isTransfer && isIncome ? '+' : '-'}$amount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isTransfer
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : isIncome
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
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
