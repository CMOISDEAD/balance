import 'package:flutter/material.dart';
import 'package:new_app/database/database.dart' as db;
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:provider/provider.dart';

final titles = {
  'income': 'Add income',
  'expense': 'Add expense',
  'transfer_to': 'Transfer to card',
  'transfer_from': 'Transfer from card',
};

final messages = {
  'income': 'Income added',
  'expense': 'Expense added',
  'transfer_to': 'Transfer to card completed',
  'transfer_from': 'Transfer from card completed',
};

class AddTransactionDialog extends StatefulWidget {
  final String type;

  const AddTransactionDialog({Key? key, required this.type}) : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();

  static Future<void> show(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(type: type),
    );
  }
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late final amountController = CurrencyHelper.createController();
  late final descriptionController = TextEditingController();
  late final categoryController = TextEditingController();
  int? selectedCardId;

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    return AlertDialog(
      title: Text(titles[widget.type] ?? 'Add Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.type == "transfer_to" || widget.type == "transfer_from")
              FutureBuilder<List<db.Card>>(
                future: provider.getAllCards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading the cards: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('There are no cards aviable.'),
                    );
                  }

                  final cards = snapshot.data!;

                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedCardId,
                        decoration: const InputDecoration(
                          labelText: 'Select the card',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        items: cards.map((card) {
                          return DropdownMenuItem<int>(
                            value: card.id,
                            child: Text(
                              card.name,
                            ), // o card.id.toString() si no tienes nombre
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCardId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            if (widget.type == "income" || widget.type == "expense")
              Column(
                children: [
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category (optional)',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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

    if (widget.type == "income" || widget.type == "expense") {
      if (amount <= 0 || description.isEmpty) {
        _showSnackBar(
          'Please enter a valid amount and description',
          Colors.orange,
        );
        return;
      }
    } else if (widget.type == "transfer_to" || widget.type == "transfer_from") {
      if (amount <= 0 || selectedCardId == null) {
        _showSnackBar(
          'Please enter a valid amount and select a card',
          Colors.orange,
        );
        return;
      }
    }

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      if (widget.type == "income") {
        await provider.addIncome(
          amount: amount,
          description: description,
          category: category.isEmpty ? null : category,
        );
      } else if (widget.type == "expense") {
        await provider.addExpense(
          amount: amount,
          description: description,
          category: category.isEmpty ? null : category,
        );
      } else if (widget.type == "transfer_to" && selectedCardId != null) {
        await provider.transferToCard(cardId: selectedCardId!, amount: amount);
      } else if (widget.type == "transfer_from" && selectedCardId != null) {
        await provider.transferFromCard(
          cardId: selectedCardId!,
          amount: amount,
        );
      }

      Navigator.pop(context);

      _showSnackBar(
        messages[widget.type] ?? 'Transaction added',
        widget.type == "expense" ? Colors.red : Colors.green,
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
