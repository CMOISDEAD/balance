import 'package:flutter/material.dart';
import 'package:balance/components/ui/transactions/transaction_tile.dart';
import 'package:balance/providers/finance_provider.dart';
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
                          children: const [Icon(Icons.chevron_right)],
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
                            return TransactionTile(
                              transaction: transaction,
                              provider: provider,
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
