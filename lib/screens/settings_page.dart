import 'package:flutter/material.dart';
import 'package:new_app/components/layout/custom_app_bar.dart';
import 'package:new_app/providers/finance_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Text('Settings'),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmDialog(context, provider);
                    },
                    child: Text("Delete all transactions"),
                  ),
                ],
              ),
            ),
          );
        },
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
