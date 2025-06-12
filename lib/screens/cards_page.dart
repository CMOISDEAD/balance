import 'package:flutter/material.dart';
import 'package:new_app/components/layout/custom_app_bar.dart';
import 'package:new_app/components/ui/balance_card.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:provider/provider.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final balance = provider.balance;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  BalanceCard(
                    title: 'Total Balance',
                    ammount: balance,
                    from: Theme.of(context).colorScheme.primaryContainer,
                    to: Theme.of(context).colorScheme.surfaceTint,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
