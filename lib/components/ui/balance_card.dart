import 'package:flutter/material.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:provider/provider.dart';

class BalanceCard extends StatelessWidget {
  final int? cardId;
  final String title;
  final double amount;
  final double? targetAmount;
  final Color from;
  final Color to;
  final bool canDelete;
  final double? total;

  const BalanceCard({
    super.key,
    this.cardId,
    required this.title,
    required this.amount,
    this.targetAmount,
    required this.from,
    required this.to,
    this.canDelete = true,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    final hasTarget = targetAmount != null && targetAmount! > 0;
    final progress = hasTarget ? (amount / targetAmount!).clamp(0.0, 1.0) : 0.0;
    final isCompleted = hasTarget && amount >= targetAmount!;
    final progressColor = isCompleted
        ? Colors.greenAccent.shade400
        : Theme.of(context).colorScheme.onPrimaryContainer;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () {
          if (canDelete && cardId != null) {
            _showDeleteDialog(context, cardId!, provider);
          }
        },
        child: Container(
          height: hasTarget ? 190 : 170,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [from, to],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Icon(
                    Icons.credit_card,
                    size: 26,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount
              Text(
                CurrencyHelper.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: amount < 0
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              // Total
              if (total != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Total: ${CurrencyHelper.formatCurrency(total)}",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              // Progress bar + percent
              if (hasTarget) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: progressColor,
                        fontWeight: isCompleted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: progressColor,
                  ),
                ),
              ],

              const Spacer(),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Currency: COP",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  if (targetAmount != null)
                    Text(
                      "Target: ${CurrencyHelper.formatCurrency(targetAmount!)}",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDeleteDialog(
  BuildContext context,
  int cardId,
  FinanceProvider provider,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Card?'),
      content: Text('Are you sure you want to delete this card?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await provider.deleteCard(cardId);
              Navigator.pop(context);
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting card'),
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
