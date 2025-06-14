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
              // Title + Amount (TopLeft)
              Positioned(
                top: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
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
                    if (total != null)
                      Text(
                        "of: ${CurrencyHelper.formatCurrency(total)}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                  ],
                ),
              ),

              // Card icon (TopRight)
              Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.credit_card,
                  size: 26,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              // Currency info (BottomLeft)
              Positioned(
                bottom: 10,
                left: 10,
                child: Text(
                  "Currency: COP",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ),

              // Target amount (BottomRight)
              if (targetAmount != null)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Target: ",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        CurrencyHelper.formatCurrency(targetAmount!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
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
