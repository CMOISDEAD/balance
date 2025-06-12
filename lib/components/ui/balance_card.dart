import 'package:flutter/material.dart';
import 'package:new_app/utils/currency_helper.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double ammount;
  final Color from;
  final Color to;
  const BalanceCard({
    super.key,
    required this.title,
    required this.ammount,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [from, to],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 150,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Stack(
          children: [
            // Title
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    CurrencyHelper.formatCurrency(ammount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ammount < 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.credit_card,
                size: 26,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Currency: COP",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
