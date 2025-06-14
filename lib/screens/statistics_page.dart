import 'package:flutter/material.dart';
import 'package:balance/components/layout/custom_app_bar.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [Text('Statistics')]),
        ),
      ),
    );
  }
}
