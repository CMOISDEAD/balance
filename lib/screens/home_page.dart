import 'package:flutter/material.dart';
import 'package:new_app/components/balance_card.dart';
import 'package:new_app/components/layout/custom_app_bar.dart';
import 'package:new_app/components/statistics.dart';
import 'package:new_app/components/transaction_history.dart';
import 'package:new_app/components/transactions/custom_home_actions.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          if (financeProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  BalanceCard(),
                  SizedBox(height: 10),
                  Statistics(),
                  SizedBox(height: 10),
                  TransactionHistory(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: CustomHomeActions(),
    );
  }
}
