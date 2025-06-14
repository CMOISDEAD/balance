import 'package:flutter/material.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:balance/utils/currency_helper.dart';
import 'package:provider/provider.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, double>>(
          future: provider.getStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text(
                'Error loading statistics: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              );
            }
            final stats = snapshot.data!;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Statistics",
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
                    SizedBox(height: 16),
                    _StatBar(
                      label: "Monthly % of Income Spent",
                      value: stats["totalExpenses"] ?? 0.0,
                      maxValue: stats["totalIncome"] ?? 1.0,
                      color: _getExpenseColor(stats),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Color _getExpenseColor(Map<String, double> stats) {
  final expenses = stats["totalExpenses"] ?? 0.0;
  final income = stats["totalIncome"] ?? 1.0;
  final ratio = expenses / income;

  if (ratio >= 0.9) return Colors.red; // 90%+ = Peligro
  if (ratio >= 0.7) return Colors.orange; // 70-89% = Precaución
  return Colors.green; // <70% = Bien
}

class _StatBar extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final double maxValue;

  const _StatBar({
    required this.color,
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = maxValue > 0
        ? (value / maxValue).clamp(0.0, 1.0)
        : 0.0;
    bool isOverBudget = value > maxValue;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Row(
              spacing: 8,
              children: [
                Text(
                  CurrencyHelper.formatCurrency(value),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (isOverBudget)
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 15,
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(16)),
          minHeight: 8,
          color: isOverBudget ? Theme.of(context).colorScheme.error : color,
          value: progressValue,
        ),
        SizedBox(height: 8),
        // Mostrar porcentaje
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(progressValue * 100).round()}%",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
