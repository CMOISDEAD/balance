import 'package:flutter/material.dart';
import 'package:balance/components/layout/custom_app_bar.dart';
import 'package:balance/components/transactions/grouped_transactions_list.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:provider/provider.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: Consumer<FinanceProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
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
                        : GroupedTransactionsList(provider: provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
