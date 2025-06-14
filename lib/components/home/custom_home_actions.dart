import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:new_app/components/home/add_transaction_dialog.dart';

ValueNotifier<bool> isDialOpen = ValueNotifier(false);

class CustomHomeActions extends StatelessWidget {
  const CustomHomeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.transparent,
      onPressed: () {
        isDialOpen.value = !isDialOpen.value;
      },
      child: SpeedDial(
        icon: Icons.add,
        openCloseDial: isDialOpen,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            labelBackgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer,
            onTap: () => {AddTransactionDialog.show(context, "income")},
            child: Icon(Icons.attach_money),
            label: 'Income',
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            labelBackgroundColor: Theme.of(context).colorScheme.errorContainer,
            onTap: () => {AddTransactionDialog.show(context, "expense")},
            child: Icon(Icons.money_off),
            label: 'Expense',
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            labelBackgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer,
            onTap: () => {AddTransactionDialog.show(context, "transfer_to")},
            child: Icon(Icons.arrow_forward),
            label: 'Move to card',
          ),
          SpeedDialChild(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            labelBackgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer,
            onTap: () => {AddTransactionDialog.show(context, "transfer_from")},
            child: Icon(Icons.arrow_back),
            label: 'Move from card',
          ),
        ],
      ),
    );
  }
}
