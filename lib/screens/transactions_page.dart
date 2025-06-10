import 'package:flutter/material.dart';
import 'package:new_app/components/layout/custom_app_bar.dart';
import 'package:new_app/components/transactions/custom_transactions_actions.dart';

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
          child: Column(children: []),
        ),
      ),
      floatingActionButton: CustomTransactionsActions(),
    );
  }
}
