import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:balance/components/ui/balance_card.dart';

class MainBalance extends StatefulWidget {
  const MainBalance({super.key});

  @override
  State<MainBalance> createState() => _MainBalance();
}

class _MainBalance extends State<MainBalance> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return BalanceCard(
          title: 'Main Balance',
          total: provider.totalBalance,
          amount: provider.balance,
          from: Theme.of(context).colorScheme.primaryContainer,
          to: Theme.of(context).colorScheme.surfaceTint,
        );
      },
    );
  }
}
