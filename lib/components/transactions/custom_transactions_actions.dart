import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:balance/providers/finance_provider.dart';
import 'package:provider/provider.dart';

ValueNotifier<bool> isDialOpen = ValueNotifier(false);

class CustomTransactionsActions extends StatelessWidget {
  const CustomTransactionsActions({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    return FloatingActionButton(
      backgroundColor: Colors.transparent,
      onPressed: () {
        isDialOpen.value = !isDialOpen.value;
      },
      child: SpeedDial(
        icon: Icons.more_vert,
        openCloseDial: isDialOpen,
        children: [
          SpeedDialChild(
            onTap: () => {_showConfirmDialog(context, provider)},
            child: Icon(Icons.delete_forever),
            label: 'Delete All',
          ),
        ],
      ),
    );
  }
}

void _showConfirmDialog(BuildContext context, FinanceProvider provider) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete All Transactions'),
      content: Text('Are you sure you want to delete all the transactions?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await provider.deleteAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All transactions deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting transaction'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete All', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
