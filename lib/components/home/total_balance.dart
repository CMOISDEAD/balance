import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/components/ui/balance_card.dart';

class TotalBalance extends StatefulWidget {
  const TotalBalance({super.key});

  @override
  State<TotalBalance> createState() => _TotalBalance();
}

class _TotalBalance extends State<TotalBalance> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return BalanceCard(
          title: 'Total Balance',
          ammount: provider.balance,
          from: Theme.of(context).colorScheme.primaryContainer,
          to: Theme.of(context).colorScheme.surfaceTint,
        );
      },
    );
  }
}
