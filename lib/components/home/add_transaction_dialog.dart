import 'package:flutter/material.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:provider/provider.dart';

class AddTransactionDialog extends StatefulWidget {
  final bool isIncome;

  const AddTransactionDialog({Key? key, required this.isIncome})
    : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();

  static Future<void> show(BuildContext context, bool isIncome) {
    return showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(isIncome: isIncome),
    );
  }
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late final amountController = CurrencyHelper.createController();
  late final descriptionController = TextEditingController();
  late final categoryController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isIncome ? 'Add Income' : 'Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _handleSubmit, child: Text('Add')),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final amount = amountController.doubleValue;
    final description = descriptionController.text.trim();
    final category = categoryController.text.trim();

    if (amount <= 0 || description.isEmpty) {
      _showSnackBar(
        'Please enter a valid amount and description',
        Colors.orange,
      );
      return;
    }

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      if (widget.isIncome) {
        await provider.addIncome(
          amount: amount,
          description: description,
          category: category.isEmpty ? null : category,
        );
      } else {
        await provider.addExpense(
          amount: amount,
          description: description,
          category: category.isEmpty ? null : category,
        );
      }

      Navigator.pop(context);
      _showSnackBar(
        widget.isIncome ? 'Income added' : 'Expense added',
        widget.isIncome ? Colors.green : Colors.red,
      );
    } catch (e) {
      _showSnackBar('Error adding transaction', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
