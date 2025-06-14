import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:new_app/components/home/main_balance.dart';
import 'package:new_app/components/layout/custom_app_bar.dart';
import 'package:new_app/components/ui/balance_card.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:new_app/utils/currency_helper.dart';
import 'package:provider/provider.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.loadCardsWithBalances();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final isLoading = provider.isLoading;
          final cards = provider.cardsWithBalances;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                MainBalance(),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (cards.isEmpty)
                  const Text('You dont have any cards yet.')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final cardData = cards[index];
                        return BalanceCard(
                          cardId: cardData.card.id,
                          title: cardData.card.name,
                          amount: cardData.balance,
                          targetAmount: cardData.card.targetAmount,
                          from: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          to: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          canDelete: true,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () {},
        child: SpeedDial(
          icon: Icons.add,
          spacing: 10,
          spaceBetweenChildren: 10,
          children: [
            SpeedDialChild(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelBackgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer,
              onTap: () => {_showAddCardDialog(context)},
              child: Icon(Icons.add_card_sharp),
              label: "Add Card",
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddCardDialog(BuildContext context) {
  final provider = Provider.of<FinanceProvider>(context, listen: false);
  final amountController = CurrencyHelper.createController();
  final nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add New Card'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Target Amount (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final amount = amountController.doubleValue;

            if (amount <= 0 || name.isEmpty) {
              // TODO: implement a snackbar or toast message
              // _showSnackBar(
              //   'Please enter a valid amount and description',
              //   Colors.orange,
              // );
              return;
            }

            try {
              provider.createCard(name: name, targetAmount: amount);
              Navigator.pop(context);
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating the card'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}
